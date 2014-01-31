using xml
using afButter

const class TextBox : Element {
	
	@NoDoc
	new fromFinder(ElemFinder elemFinder) : super(elemFinder) { }
	
	Str value {
		get { isTextArea ? innerHtml : getAttr("value") }
		set { 
			elem := findElem
			if (isTextArea(elem)) {
				elem.children.each { elem.remove(it) }
				elem.add(XText(it))
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
	
	override ButterResponse submitForm() {
		super.submitForm
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
