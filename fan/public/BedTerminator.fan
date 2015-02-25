using afIocConfig
using afButter
using afButter::HttpResponseHeaders as ButtHead
using afBedSheet::BedSheetConfigIds
using afBedSheet::HttpResponseHeaders
using afBedSheet::MiddlewarePipeline
using web::Cookie
using web::WebOutStream
using web::WebMod
using web::WebReq
using web::WebRes
using web::WebSession
using inet
using concurrent::Actor

** A 'Butter' terminator that makes requests against a given `BedServer`.
class BedTerminator : ButterMiddleware {
	
	private WebSession?	session

	** The 'BedServer' this terminator makes calls against.
	BedServer bedServer


	** Create a BedTerminator attached to the given 'BedServer'
	internal new make(BedServer bedServer) {
		this.bedServer 	= bedServer
		this.session	= BounceWebSession()
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
			req.headers.contentLength = req.body.buf.size
		}

		try {
			bounceWebRes := BounceWebRes()
			
			Actor.locals["web.req"] = toWebReq(req, session)
			Actor.locals["web.res"] = bounceWebRes

			pipeline := (MiddlewarePipeline) bedServer.registry.dependencyByType(MiddlewarePipeline#)
			pipeline.service
			
			return bounceWebRes.toButterResponse

		} finally {
			Actor.locals.remove("web.req")
			Actor.locals.remove("web.res")
		}		
	}
	
	** Shuts down the associated 'BedServer' and the running web app.
	Void shutdown() {
		bedServer.shutdown
	}

	** The session used by the client.
	** 
	** If a session has not yet been created then it returns 'null' - or creates a new session if 
	** 'create' is 'true'.
	WebSession?	webSession(Bool create := false) {
		// the null thing is for bounce clients to know if the session has been created or not. Technically this is not 
		// perfect wisp behaviour, for if an obj were to be added then immediately removed, a wisp session would still 
		// be created - pfft! Edge case! 
		(session.map.isEmpty && !create) ? null : session 
	}
	
	internal WebReq toWebReq(ButterRequest req, WebSession session) {
		BounceWebReq {
			it.version	= req.version
			it.method	= req.method
			it.uri		= req.url
			it.headers	= req.headers.map
			it.session	= session
			it.in		= req.body.buf.seek(0).in
		}
	}
}



internal class BounceWebReq : WebReq {
	private static const WebMod webMod := BounceDefaultMod() 
	
	override WebMod mod 					:= webMod
	override IpAddr remoteAddr()			{ IpAddr("127.0.0.1") }
	override Int remotePort() 				{ 80 }
	override SocketOptions socketOptions()	{ TcpSocket().options }
	
	override Version 	version
	override Str 		method
	override Uri 		uri
	override Str:Str 	headers
	override WebSession	session
	override InStream 	in
	
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
		myStatusRes	 := statusMsg[myStatusCode]
		myHeaders	 :=	ButtHead {
			keyVals  := it.convertMap(&headers)
			myCookies.each |cookie| {
				keyVals.add(KeyVal("Set-Cookie", cookie.toStr))
			}
			it.keyVals = keyVals
		}
		
		return ButterResponse {
			it.statusCode 	= myStatusCode
			it.statusMsg	= myStatusRes ?: "Unknown Status Code"
			it.body.buf		= buf
//			it.headers 		= myHeaders	// FIXME!! 
		}
	}
}



internal class BounceWebSession : WebSession {
	static const Cookie sessionCookie	:= Cookie("fanws", "69")
	
	override Str id {
		get { createSession; return "69" }
		set { }
	}
	
	override Str:Obj? map {
		get { createSession; return &map }
	}
	
	new make() { this.map = Str:Obj?[:] }

	override Void delete() {
		&map.clear
	}
	
	override Str toStr() {
		"id=${id}, ${&map.toStr}"
	}

	private Void createSession() {
		webReq := (WebReq?) Actor.locals["web.req"]
		webRes := (WebRes?) Actor.locals["web.res"]
		
		if (webReq == null || webRes == null)
			return
		
		if (!webReq.cookies.containsKey("fanws")) {
			if (!webRes.cookies.any { it.name == "fanws" })
			webRes.cookies.add(sessionCookie)
		}
	}
}



internal const class BounceDefaultMod : WebMod { }
