//using afBounce
using afButter

class TestFantomFactory : Test {

    Void testFantomFactory() {
        // add Sizzle to the default middleware stack
        client := BedClient(Butter.churnOut(
            Butter.defaultStack.insert(0, SizzleMiddleware())
        ))

        // make real http requests to your integration environment
		// make Butter follow some redirects - real life ain't easy!
        client.get(`http://www.fantomfactory.org/pods/afBounce`)

        // use sizzle to test
        tagLine := Element("h1.podHeading .small")
        tagLine.verifyTextEq("A headless browser for testing web sites and BedSheet applications")
    }
}
