using xml
using afButter

** (HTML Element) 
const class TextBox : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }
	
	Str name() {
		getAttr("name") ?: ""
	}

	Str value {
		get { isTextArea ? text : getAttr("value") }
		set { 
			elem := findElem
			if (isTextArea(elem)) {
				elem.children.each { elem.remove(it) }
				elem.add(XText(it))
				return
			}
			setAttr("value", it, elem)
		}
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
	
	Void verifyValueEq(Obj expected) {
		verifyEq(value, expected)	
	}
	
	override protected XElem findElem() {
		elem := super.findElem
		if (!isTextArea(elem) && !isInput(elem))
			fail("TextBox is NOT of type <textarea> or <input>")
		// we could assert on the input type here, but with do many HTML5 types being added and removed, I think we'll
		// wait for a standard to emerge first!
		return elem
	}
	
	private Bool isTextArea(XElem elem := findElem) {
		elem.name.equalsIgnoreCase("textarea")
	}
	
	private Bool isInput(XElem elem) {
		elem.name.equalsIgnoreCase("input")
	}
}
