using xml
using afButter

// TODO: SelectBox
** (HTML Element) 
const class SelectBox : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }
	
	Str name() {
		getAttr("name") ?: ""
	}

	Bool enabled {
		get { getAttr("disabled") == null }
		set { setAttr("disabled", it ? null : "disabled") }
	}

	Bool disabled {
		get { getAttr("disabled") != null }
		set { setAttr("disabled", it ? "disabled" : null) }
	}
	
	ButterResponse submitForm() {
		super.submitEnclosingForm
	}
	
//	Void verifyValueEq(Obj expected) {
//		verifyEq(value, expected)	
//	}

	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("select"))
			fail("Element is NOT a <select>", false)
		return elem
	}
}