//using afBounce
using afButter

class TestFantomFactory : Test {

    Void testFantomFactory() {
        // add Sizzle to the default middleware stack
        client := BedClient(Butter.churnOut(
            Butter.defaultStack.insert(0, SizzleMiddleware())
        ))

        // make real http requests to your integration environment
        client.get(`http://www.fantomfactory.org/pods/afBounce`)

        // use sizzle to test
        tagLine := Element(".jumbotronic h1 + p")
        tagLine.verifyTextEq("A library for testing BedSheet applications")
    }
}
