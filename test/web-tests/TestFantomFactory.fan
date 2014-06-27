//using afBounce
using afButter

class TestFantomFactory : Test {

    Void testFantomFactory() {
        // add Sizzle to the middleware stack
        client := BedClient(Butter.churnOut(
            Butter.defaultStack.insert(0, SizzleMiddleware())
        ))

        // make real http requests to your integration environment
        client.get(`http://www.fantomfactory.org/pods/afBounce`)

        // use sizzle to test
        tagLine := Element(".jumbotron h1 + p")
        tagLine.verifyTextEq("A library for testing BedSheet applications!")
    }
}
