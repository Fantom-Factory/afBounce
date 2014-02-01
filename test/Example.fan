//using afBounce
//using afBedSheet::Text
//using afBedSheet::Route
//using afBedSheet::Routes
//using afIoc
//
//internal class Example : Test {
//	Void testBedApp() {
//		// given
//		server := BedServer(Type.find("Example_0::AppModule")).startup
//		client := server.makeClient
//		
//		// when
//		client.get(`/index`)
//		
//		// then
//		title := client.selectCss("#title").first
//		verifyEq(title.text.writeToStr, "Sizzle Kicks Ass!")
//		
//		// cleanup
//		server.shutdown
//	}	
//}
//
//** A Really Simple Bed App!!!
//internal class AppModule {
//	@Contribute { serviceType=Routes# }
//	static Void contributeRoutes(OrderedConfig config) {
//		config.add(Route(`/index`, Text.fromHtml("""<html><p id="title">Sizzle Kicks Ass!</p></html>""")))
//	}
//}
