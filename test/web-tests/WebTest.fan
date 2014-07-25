using afIoc::Inject
using afBedSheet
using afIoc

internal class WebTest : Test {

	BedServer?	server
	BedClient?	client
	
	override Void setup() {
		Log.get("afIoc").level 		= LogLevel.warn
		Log.get("afIocEnv").level	= LogLevel.warn
		
		server = BedServer(T_AppModule#).startup
		client = server.makeClient
	}	

	override Void teardown() {
		client.shutdown
	}	
}


internal class T_AppModule {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration config) {
		config.add(Route(`/index`,		Text.fromHtml("""<html><p id="title">Sizzle Kicks Ass!</p></html>""")))
		config.add(Route(`/session`, 	T_PageHandler#countReqs))
		config.add(Route(`/formTest`, 	`test/web-tests/formTest.html`.toFile))
		config.add(Route(`/bounce`, 	`test/web-tests/bounce.html`.toFile))
		config.add(Route(`/printForm`, 	#printForm, "POST"))
		config.add(Route(`/printFormAlt`, #printForm, "WEIRD"))
	}
	
	static Text printForm(HttpRequest? req := null) {
		Text.fromPlain(req.form.toCode)
	}
}

internal const class T_PageHandler {
	@Inject	private const HttpSession 		session
	
	new make(|This|in) { in(this) }
	
	Obj countReqs() {
		count := (Int) session.get("count", 0)
		count += 1
		session["count"] = count
		return Text.fromPlain("count $count")
	}
}