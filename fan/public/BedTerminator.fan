using afIoc::Registry
using afIocConfig
using afButter
using afButter::HttpResponseHeaders as ButtHead
using afBedSheet::BedSheetConfigIds
using afBedSheet::HttpResponseHeaders
using afBedSheet::MiddlewarePipeline
using afBedSheet::SessionValue
using web::Cookie
using web::WebOutStream
using web::WebMod
using web::WebReq
using web::WebRes
using web::WebSession
using web::WebUtil
using inet::IpAddr
using inet::SocketOptions
using inet::TcpSocket
using concurrent::Actor

** A 'Butter' terminator that makes requests against a given `BedServer`.
class BedTerminator : ButterMiddleware {
	
	// this is weird place to hold the session - but it's needed by WebReq
	internal BounceWebSession	_session

	** The 'BedServer' this terminator makes calls against.
	BedServer bedServer

	** Create a BedTerminator attached to the given 'BedServer'
	new make(BedServer bedServer) {
		this.bedServer 	= bedServer
		this._session	= BounceWebSession()
	}

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!req.url.isRel)
			throw Err("Request URIs for Bed App testing should only be a path, e.g. `/index` vs `${req.url}`")
		if (!req.url.isPathAbs)
			throw Err("Request URIs for Bed App testing should start with a slash, e.g. `/index` vs `${req.url}`")

		// set the Host (as configured in BedSheet), if it's not been already
		if (req.headers.host == null) {
			confSrc := (ConfigSource) bedServer.serviceById(ConfigSource#.qname)
			bsHost 	:= (Uri) confSrc.get(BedSheetConfigIds.host, Uri#)
			req.headers.host = HttpTerminator.normaliseHost(bsHost)
		}

		// set the Content-Length, if it's not been already
		if (req.headers.contentLength == null && req.method != "GET") {
			req.headers.contentLength = req.body.buf?.size ?: 0
		}

		try {
			bounceWebRes := BounceWebRes()
			
			Actor.locals["web.req"] = toWebReq(req, _session)
			Actor.locals["web.res"] = bounceWebRes

			pipeline := (MiddlewarePipeline) bedServer.serviceById(MiddlewarePipeline#.qname)
			bedServer.registry.rootScope.createChild("request") {
				pipeline.service
			}
			
			return bounceWebRes.toButterResponse

		} finally {
			((WebReq) Actor.locals["web.req"]).stash.clear
			Actor.locals.remove("web.req")
			Actor.locals.remove("web.res")
			Actor.locals.remove("web.session")
		}		
	}
	
	internal WebReq toWebReq(ButterRequest req, WebSession session) {
		return BounceWebReq {
			it.version	= req.version
			it.method	= req.method
			it.uri		= req.url
			it.headers	= req.headers.val
			it.session	= session
			it.reqBodyBuf = req.body.buf?.seek(0) ?: Buf()
		}
	}
}



internal class BounceWebReq : WebReq {
	private static const WebMod webMod := BounceDefaultMod() 
	
			 Buf reqBodyBuf
	override WebMod mod 					:= webMod
	override IpAddr remoteAddr()			{ IpAddr("127.0.0.1") }
	override Int remotePort() 				{ 80 }
	override SocketOptions	socketOptions()	{ TcpSocket().options }
	override TcpSocket 		socket()		{ TcpSocket() }
	
	override Version 	version
	override Str 		method
	override Uri 		uri
	override Str:Str 	headers
	override WebSession	session {
		get {
			// Wisp creates the session cookie as soon as the WebSession is returned
			((BounceWebSession) &session).create
			return &session
		}
	}
	override InStream 	in() {
		if (reqBodyBuf.size == 0)
			throw Err("Attempt to access WebReq.in with no content")
		return reqBodyBuf.in
	}
	
	new make(|This|in) { in(this) }
}



** Adapted from WispReq to mimic the same uncommitted behaviour 
internal class BounceWebRes : WebRes {
	private Buf				buf
	private WebOutStream	webOut

	new make() {
		this.buf		= Buf() 
		this.webOut		= WebOutStream(buf.out)
		this.headers	= Str:Str[:] { it.caseInsensitive = true }
		this.cookies	= [,]
	}

	override TcpSocket upgrade(Int statusCode := 101) {
		throw UnsupportedErr()
	}
	
	override Int statusCode := 200 {
		set {
			checkUncommitted
			&statusCode = it
		}
	}

	override Str:Str headers {
		get { checkUncommitted; return &headers }
	}

	override Cookie[] cookies {
		get { checkUncommitted; return &cookies }
	}

	override Bool isCommitted := false { private set }

	override WebOutStream out()	{
		commit
		return webOut
	}

	override Void redirect(Uri uri, Int statusCode := 303) {
		checkUncommitted
		this.statusCode = statusCode
		headers["Location"] = uri.encode
		headers["Content-Length"] = "0"
		commit
		done
	}

	override Void sendErr(Int statusCode, Str? msg := null)	{
		// write message to buffer
		buf := Buf()
		bufOut := WebOutStream(buf.out)
		bufOut.docType
		bufOut.html
		bufOut.head.title.w("$statusCode ${statusMsg[statusCode]}").titleEnd.headEnd
		bufOut.body
		bufOut.h1.w(statusMsg[statusCode]).h1End
		if (msg != null) bufOut.w(msg).nl
		bufOut.bodyEnd
		bufOut.htmlEnd

		// write response
		checkUncommitted
		this.statusCode = statusCode
		headers["Content-Type"] = "text/html; charset=UTF-8"
		headers["Content-Length"] = buf.size.toStr
		this.out.writeBuf(buf.flip)
		done
	}

	override Bool isDone := false { private set }

	override Void done() { isDone = true }

	internal Void checkUncommitted() {
		if (isCommitted) throw Err("WebRes already committed")
	}

	internal Void commit() {
		if (isCommitted) return
		isCommitted = true
	}

	internal Void close() {
		commit
		webOut.close
	}

	internal ButterResponse toButterResponse() {
		myStatusCode := &statusCode
		myCookies 	 := &cookies
		myHeaders	 :=	ButtHead {
			keyVals  := it.convertMap(&headers)
			myCookies.each |cookie| {
				keyVals.add(KeyVal("Set-Cookie", cookie.toStr))
			}
			it.keyVals = keyVals
		}
		res:= ButterResponse(myStatusCode, myHeaders.val, buf)
		return res
	}
}



** I know HttpSession wraps data up in SessionValues - we do it here too so that direct users of
** WebSession don't need to know it exists - as used when setting session data directly, 
** e.g. setting a logged in user
internal class BounceWebSession : WebSession {
	
	Bool exists
	
	override Str id {
		get {
			val := findSessionCookie?.val ?: "???"
			// try to retain original unquoted session cookie ID for SleepSafe
			return val[0] != '"' ? val : WebUtil.fromQuotedStr(val)
		}
		set { }
	}
	
	override Str:Obj? map {
		get {
			map := Str:Obj?[:]
			&map.each |val, key| {
				map[key] = val is SessionValue ? ((SessionValue) val).val : val
			} 
			return map
		}
	}
	
	new make() { this.map = Str:Obj?[:] }

	override Void delete() {
		&map.clear

		// follow wisp behaviour
		if (exists) {
			webRes := (WebRes?) Actor.locals["web.res"]
			webRes?.cookies?.add(Cookie("fanws", id) { maxAge=0sec })
		}
		
		exists = false
	}
	
	override Void each(|Obj?, Str| f) {
		&map.each(f)
	}
	
	@Operator
	override Obj? get(Str name, Obj? def := null) {
		val := &map.get(name, def)
		// flash is an internal BedSheet thing, as used by BedSheet, so always return the raw value
		if (name == "afBedSheet.flash") return val
		return val is SessionValue ? ((SessionValue) val).val : val
	}
	
	@Operator
	override Void set(Str name, Obj? val) {
		if (val is SessionValue)
			&map.set(name, val)
		else
			&map.set(name, SessionValue.coerce(val))
	}
	
	override Void remove(Str name) {
		&map.remove(name)
	}
	
	override Str toStr() {
		"id=${id}, ${map}"
	}

	Void create() {
		if (exists)	return

		exists = true

		webReq := (WebReq?)		Actor.locals["web.req"]
		webRes := (WebRes?)		Actor.locals["web.res"]
		webSes := (WebSession?)	Actor.locals["web.session"]
		
		if (webReq == null || webRes == null)
			return

		// note we're now committed to recovering or creating a session
		if (findSessionCookie == null)
			webRes.cookies.add(Cookie("fanws", Int.random.toHex.upper))

		// this is what Wisp does - bounce / bedsheet doesn't need it
		Actor.locals["web.session"] = this
	}
	
	Cookie? findSessionCookie() {
		webReq := (WebReq?) Actor.locals["web.req"]
		reqStr := webReq?.cookies?.get("fanws")
		reqCok := reqStr == null ? null : Cookie("fanws", reqStr)
		webRes := (WebRes?) Actor.locals["web.res"]
		resCok := webRes?.cookies?.find { it.name == "fanws" }
		return reqCok ?: resCok
	}
}



internal const class BounceDefaultMod : WebMod { }
