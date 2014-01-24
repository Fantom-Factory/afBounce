using afButter
using afSizzle
using xml::XElem
using web::WebSession

** Use to send requests to your Bed App. 
class BedClient : ButterDish {
	new make(Butter butter) : super(butter) { }

	
	
	// ---- Sizzle Methods ---------------------------------------------------------------------------------------------
	
	XElem rootElement() {
		sizzle.sizzleDoc.rootElement
	}

	XElem[] selectCss(Str cssSelector) {
		sizzle.select(cssSelector)
	}

	
	
	// ---- BedTerminator Methods --------------------------------------------------------------------------------------
	
	** Shuts down the associated 'BedServer' and the running web app.
	Void shutdown() {
		bedTerminator.shutdown
	}

	** The 'BedServer' this terminator makes calls against.
	BedServer bedServer {
		get { bedTerminator.bedServer }
		set { }
	}

	** The 'WebSession' this client has in the Bed App. Returns 'null' if it has not yet been created.
	WebSession?	webSession {
		get { bedTerminator.session }
		set { }
	}

	
	
	// ---- Private Methods --------------------------------------------------------------------------------------------
	
	private SizzleMiddleware sizzle() {
		findMiddleware(SizzleMiddleware#)
	}
	
	private BedTerminator bedTerminator() {
		findMiddleware(BedTerminator#)
	}
}
