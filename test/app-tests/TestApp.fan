using afButter

class TestApp : Test {
	
	Void testApp() {
		
		bedServer := BedServer(T_AppModule#).startup
		butter := BounceButterDish(Butter.churnOut([
			SizzleMiddleware(),
			BedTerminator(bedServer)
		]))
		
		res := butter.get(`/index`)
		
		elem := butter.select("#title")
		verifyEq(elem.first.text.writeToStr, "Sizzle Kicks Ass!")
	}
	
}
