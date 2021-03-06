using xml
using afButter

** (HTML Element) Represents a form '<input>' of type 'text' or a '<textarea>'.
const class TextBox : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }
	
	** Return the 'name' attribute.
	Str name() {
		getAttr("name") ?: ""
	}

	** Gets and sets the 'value' attribute.
	** Returns 'null' if the value has not been set.
	Str? value {
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

	** Gets and sets the 'disabled' attribute (inverted).
	Bool enabled {
		get { getAttr("disabled") == null }
		set { setAttr("disabled", it ? null : "disabled") }
	}

	** Gets and sets the 'disabled' attribute.
	Bool disabled {
		get { getAttr("disabled") != null }
		set { setAttr("disabled", it ? "disabled" : null) }
	}
	
	** Verify that the textbox has the given value.
	Void verifyValueEq(Obj expected) {
		verifyEq(value, expected)	
	}
	
	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!isTextArea(elem) && !isInput(elem))
			fail("TextBox is NEITHER a <textarea> nor <input>: ", false)
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
