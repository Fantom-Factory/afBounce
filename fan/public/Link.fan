using xml
using afButter

** (HTML Element) Represents an anchor element '<a>'.
** 
** Because form (submit) buttons are often used as links, 'Link' may also represent a 
** 'SubmitButton'. Clicking a button will submit the enclosing form.
const class Link : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

	** Returns the 'href' attribute.
	Uri href() {
		toSubmitButton.isSubmit(findElem)
			? Uri.decode(getAttr("formaction") ?: Attr(findForm)["action"])
			: Uri.decode(getAttr("href"))
	}
	
	** Sends a GET request to the Bed App with the uri from the 'href' attribute. 
	ButterResponse click() {
		toSubmitButton.isSubmit(findElem)
			? toSubmitButton.click
			: bedClient.get(href)
	}
	
	** Verify that the value of the href is equal to the given. 
	Void verifyHrefEq(Obj expected) {
		verifyEq(href.toStr, expected)	
	}
	
	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("a") && !toSubmitButton.isSubmit(elem))
			fail("Element is NOT a link: ", false)
		return elem
	}	
}