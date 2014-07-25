using xml
using afButter

** (HTML Element) Represents a anchor element '<a>'.
const class Link : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

	** Returns the 'href' attribute.
	Str href() {
		getAttr("href")
	}
	
	** Sends a GET request to the Bed App with the uri from the 'href' attribute. 
	ButterResponse click() {
		bedClient.get(href.toUri)
	}
	
	** Verify that the value of the href is equal to the given. 
	Void verifyHrefEq(Obj expected) {
		verifyEq(href, expected)	
	}
	
	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("a"))
			fail("Element is NOT a link: ", false)
		return elem
	}
}