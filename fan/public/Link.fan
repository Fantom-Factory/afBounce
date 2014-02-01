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
	
	** Submits an enclosing form to Bed App.
	ButterResponse submitForm() {
		super.submitEnclosingForm
	}
	
	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("a"))
			fail("Element is NOT a link", false)
		return elem
	}
}