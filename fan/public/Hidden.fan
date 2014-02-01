using xml
using afButter

** (HTML Element) Represents a form '<input>' of type 'hidden'.
const class Hidden : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

	** Returns the 'name' attribute.
	Str? name() {
		getAttr("name")
	}

	** Gets and sets the 'value' attribute.
	Str value {
		get { getAttr("value") }
		set { setAttr("value", it) }
	}
	
	** Submits the enclosing form to the Bed App.
	ButterResponse submitForm() {
		super.submitEnclosingForm
	}
	
	** Verify that the hidden element has the given value.
	Void verifyValueEq(Obj expected) {
		verifyEq(value, expected)	
	}

	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("input") && !(elem.attr("type", false)?.val?.equalsIgnoreCase("hidden") ?: false))
			fail("Element is NOT a hidden input", false)
		return elem
	}
}
