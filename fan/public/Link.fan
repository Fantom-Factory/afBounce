using xml
using afButter

** (HTML Element) 
const class Link : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

	Str href() {
		getAttr("href")
	}
	
	ButterResponse click() {
		bedClient.get(href.toUri)
	}
	
	ButterResponse submitForm() {
		super.submitEnclosingForm
	}
	
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("a"))
			fail("Element is NOT a link")
		return elem
	}
}