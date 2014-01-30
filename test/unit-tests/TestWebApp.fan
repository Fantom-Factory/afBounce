using afIoc::Inject
using afBedSheet::Route
using afBedSheet::Routes
using afBedSheet::Text
using afBedSheet::HttpSession
using afIoc

class TestWebApp : Test {
	
	Void testBedApp() {
		// given
		server := BedServer(T_AppModule#).startup
		client := server.makeClient
		
		// when
		client.get(`/index`)
		
		// then
		title := Element("#title")
		title.verifyTextEq("Sizzle Kicks Ass!")

		client.shutdown
	}	

	Void testWebSession() {
		server := BedServer(T_AppModule#).startup
		client := server.makeClient
			
		client.get(`/index`)
		verifyNull(client.webSession)
		
		verifyEq(client.get(`/session`).asStr, "count 1")
		verifyNotNull(client.webSession)
		
		verifyEq(client.get(`/session`).asStr, "count 2")
		verifyEq(client.get(`/session`).asStr, "count 3")
		
		client = server.makeClient
		verifyEq(client.get(`/session`).asStr, "count 1")
		client.shutdown
	}	
}

internal class T_AppModule {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(OrderedConfig config) {
		config.add(Route(`/index`,		Text.fromHtml("""<html><p id="title">Sizzle Kicks Ass!</p></html>""")))
		config.add(Route(`/session`, 	T_PageHandler#countReqs))
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
