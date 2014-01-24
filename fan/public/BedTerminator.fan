using afIocConfig
using afButter
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
	
	** The 'BedServer' this terminator makes calls against.
	BedServer bedServer
	
	** The session used by the client. Returns 'null' if it has not yet been created.
	WebSession?	session	:= BounceWebSession() {
		// the null thing is for bounce clients to know if the session has been created or not. Technically this is not 
		// perfect wisp behaviour, for if an obj were to be added then immediately removed, a wisp session would still 
		// be created - pfft! Edge case! 
		get {
			&session.map.isEmpty ? null : &session 
		}
		private set { }
	}
	
	** Create a BedTerminator attached to the given 'BedServer'
	internal new make(BedServer bedServer) {
		this.bedServer = bedServer
	}

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!req.uri.isPathOnly)
			throw Err("Request URIs for Bed App testing should only be a path, e.g. `/index` vs `${req.uri}`")
		if (!req.uri.isPathAbs)
			throw Err("Request URIs for Bed App testing should start with a slash, e.g. `/index` vs `${req.uri}`")

		// set the Host (as configured in BedSheet), if it's not been already
		if (req.headers.host == null) {
			confSrc := (IocConfigSource) bedServer.dependencyByType(IocConfigSource#)
			bsHost 	:= (Uri) confSrc.get(BedSheetConfigIds.host, Uri#)
			isHttps := bsHost.scheme == "https"
			defPort := isHttps ? 443 : 80
			host 	:= bsHost.host
			if (bsHost.port != null && bsHost.port != defPort)
				host += ":${bsHost.port}"
			req.headers.host = host.toUri
		}

		// set the Content-Length, if it's not been already
		if (req.headers.contentLength == null && req.method != "GET") {
			req.headers.contentLength = req.body.size
		}

		try {
			bounceWebRes := BounceWebRes()
			
			Actor.locals["web.req"] = toWebReq(req, &session)
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
	
	internal WebReq toWebReq(ButterRequest req, WebSession session) {
		BounceWebReq {
			it.version	= req.version
			it.method	= req.method
			it.uri		= req.uri
			it.headers	= req.headers.map
			it.session	= session
			it.in		= req.body.seek(0).in
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
		// FIXME: WebUtil.parseHeaders() can't handle more than 1 Set-Cookie, as the max-age contains a ','
		if (!&cookies.isEmpty)
			&headers["Set-Cookie"] = &cookies.first.toStr
		return ButterResponse(&statusCode, statusMsg[statusCode], &headers, buf)
	}
}



internal class BounceWebSession : WebSession {
	override const Str id := "69"
	override Str:Obj? map := Str:Obj[:]
	override Void delete() {
		map.clear
	}
}



internal const class BounceDefaultMod : WebMod { }
