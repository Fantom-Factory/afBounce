using afBedSheet::Route
using afBedSheet::Routes
using afBedSheet::Text
using afIoc

class TestWebApp : Test {
	Void testBedApp() {
		// given
		server := BedServer(T_AppModule#).startup
		client := server.makeClient
		
		// when
		client.get(`/index`)
		
		// then
		title := client.select("#title").first
		verifyEq(title.text.writeToStr, "Sizzle Kicks Ass!")
	}	
}

internal class T_AppModule {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(OrderedConfig config) {
		config.add(Route(`/index`, Text.fromHtml("""<html><p id="title">Sizzle Kicks Ass!</p></html>""")))
	}
}

