using afBedSheet
using afIoc

internal class WebTest : Test {

	BedServer?	server
	BedClient?	client
	
	override Void setup() {
		Log.get("afIoc").level 		= LogLevel.warn
		Log.get("afIocEnv").level	= LogLevel.warn
		Log.get("afBedSheet").level = LogLevel.warn
		
		server = BedServer(T_AppModule#).startup
		client = server.makeClient		
	}	

	override Void teardown() {
		client?.shutdown
	}
}

// if the projects are open in F4, then the meta doesn't get built and the modules don't get added!
internal const class T_AppModule {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration config) {
		config.add(Route(`/index`,		Text.fromHtml("""<html><p id="title">Sizzle Kicks Ass!</p></html>""")))
		config.add(Route(`/session`, 	T_PageHandler#countReqs))
		config.add(Route(`/formTest`, 	`test/web-tests/formTest.html`.toFile))
		config.add(Route(`/bounce`, 	`test/web-tests/bounce.html`.toFile))
		config.add(Route(`/printForm`, 	T_AppThing#printForm, "POST"))
		config.add(Route(`/printFormAlt`, T_AppThing#printForm, "GET POST"))
		config.add(Route(`/urlTest`, 	`test/web-tests/urlTest.html`.toFile))
		config.add(Route(`/printUrl/**`, T_AppThing#printUrl, "GET POST"))
	}
}

internal class T_AppThing {
	@Inject
	HttpRequest? req
	Text printForm() {
		Text.fromPlain(req.body.form?.toCode ?: req.url.query.toCode)
	}
	
	Text printUrl(Uri stuff) {
		Text.fromPlain(req.url.toStr)
	}
}

internal const class T_PageHandler {
	@Inject	private const HttpSession session
	
	new make(|This|in) { in(this) }
	
	Obj countReqs() {
		count := (Int) session.get("count", 0)
		count += 1
		session["count"] = count
		return Text.fromPlain("count $count")
	}
}