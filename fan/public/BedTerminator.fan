using afButter
using afBedSheet::HttpPipeline
using web::Cookie
using web::WebOutStream
using web::WebMod
using web::WebReq
using web::WebRes
using web::WebSession
using inet
using concurrent::Actor

class BedTerminator : ButterMiddleware {
	
	private BedServer bedServer
	
	** The session used by the client. Returns 'null' if it has not yet been created.
	WebSession?	session	:= BounceWebSession() {
		// emulate wisp behaviour, so BedSheet gets a *real* experience
		get {
			// technically this is not perfect wisp behaviour, for if an obj were to be added then 
			// immediately removed, a wisp session would still be created - pfft! Edge case! 
			// Besides if you need exact wisp behaviour, then use wisp!
			&session.map.isEmpty ? null : &session 
		}
		private set { }
	}
	
	** Create a BedTerminator attached to the given 'BedServer'
	internal new make(BedServer bedServer) {
		this.bedServer = bedServer
	}

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		try {
			bounceWebRes := BounceWebRes()
			
			Actor.locals["web.req"] = toWebReq(req, session)
			Actor.locals["web.res"] = bounceWebRes

			httpPipeline := (HttpPipeline) bedServer.registry.dependencyByType(HttpPipeline#)
			httpPipeline.service
			
//			bounceWebRes.cookies.each |cookie| { this.cookies[cookie.name] = cookie }

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
			it.headers	= req.headers
			it.session	= session
			it.in		= req.in ?: "".in
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
			Buf				buf
	private WebOutStream	webOut

	new make() {
		this.buf		= Buf() 
		this.webOut		= WebOutStream(buf.out)
		this.headers	= [:] { it.caseInsensitive = true }
		this.cookies	= [,]
	}

	override Int statusCode := 200 {
		set {
			checkUncommitted
			if (statusMsg[it] == null) throw Err("Unknown status code: $it");
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
		
		// TODO: what do we do about these? We should print them and let other middleware decode them
//	    // write response line and headers
//	    sout.print("HTTP/1.1 ").print(statusCode).print(" ").print(toStatusMsg).print("\r\n");
//	    &headers.each |Str v, Str k| { sout.print(k).print(": ").print(v).print("\r\n") };
//	    &cookies.each |Cookie c| { sout.print("Set-Cookie: ").print(c).print("\r\n") }
//	    sout.print("\r\n").flush		
	}

	internal Void close() {
		commit
		webOut.close
	}

	internal ButterResponse toButterResponse() {
		ButterResponse()
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
