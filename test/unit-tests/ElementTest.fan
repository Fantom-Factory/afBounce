using xml
using afSizzle
using concurrent

internal class ElementTest : Test {
	
	override Void teardown() {
		Actor.locals.remove("afBounce.sizzleDoc")
	}
	
	Void testGetAtIndex() {
		xhtml := "<p><a>foo</a><a>bar</a></p>"
        Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(xhtml)

		// used to get cast err if not Element
		links := Link("a")
		
		links[0].verifyTextEq("foo")
		links[1].verifyTextEq("bar")
	}

}
