using concurrent
using afButter
using afSizzle
using xml::XElem
using web::Cookie
using web::WebSession

** Use to send requests to your Bed App. 
class BedClient : ButterDish {
	
	** The last request. 
	** Returns 'null' if no requests have been made.  
	ButterRequest? lastRequest

	** The response to the last request. 
	** Returns 'null' if no requests have been made.  
	ButterResponse? lastResponse
	
	new make(Butter butter) : super(butter) { }
	

	static BedClient getThreadedClient() {
		client := (BedClient?) Actor.locals["afBounce.bedClient"]
		if (client == null)
			throw Err("Threaded BedClient does not exist until you make a request!")
		return client
	}


	Void refresh() {
		if (lastRequest == null)
			throw Err("There is no 'lastRequest' to refresh!")
		sendRequest(lastRequest)
	}
	
	// ---- Sizzle Methods ---------------------------------------------------------------------------------------------
	
	** Returns 'SizzleDoc' of the XML response.
	SizzleDoc sizzleDoc() {
		sizzle.sizzleDoc
	}

	** Returns the root XML element of the response
	XElem rootElement() {
		sizzle.sizzleDoc.rootElement
	}

	** Selects XML elements from the XML response
	XElem[] selectCss(Str cssSelector) {
		sizzle.select(cssSelector)
	}

	
	
	// ---- BedTerminator Methods --------------------------------------------------------------------------------------
	
	** Shuts down the associated 'BedServer' and the running web app.
	Void shutdown() {
		Actor.locals.remove("afBounce.bedClient")
		bedServer.shutdown
	}

	** The 'BedServer' this terminator makes calls against.
	BedServer bedServer {
		get { bedTerminator.bedServer }
		set { }
	}

	** The 'WebSession' this client has in the Bed App. 
	** 
	** If a session has not yet been created then it returns 'null' - or creates a new session if 
	** 'create' is 'true'.
	WebSession?	webSession(Bool create := false) {
		session := bedTerminator._session
		if (session.exists)
			return session
		if (create == false)
			return null
		
		session.create
		cookieName := Env.cur.config(WebSession#.pod, "sessionCookieName", "fanws")
		// cookie is null if we're not part of a web request - which would be the norm
		cookie := session.findSessionCookie ?: Cookie(cookieName, Int.random.toHex.upper)
		super.stickyCookies.addCookie(cookie)

		return session
	}

	
	
	// ---- Private Methods --------------------------------------------------------------------------------------------
	
	override ButterResponse sendRequest(ButterRequest req) {
		// enable threaded sizzledoc 
		Actor.locals["afBounce.bedClient"] = this
		lastRequest = req
		lastResponse = super.sendRequest(req)
		return lastResponse
	}

	private SizzleMiddleware sizzle() {
		findMiddleware(SizzleMiddleware#)
	}

	private BedTerminator bedTerminator() {
		findMiddleware(BedTerminator#)
	}
}
