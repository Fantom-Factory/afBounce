using xml
using afButter

** (HTML Element) Represents a form '<input>' of type 'checkbox'.
const class CheckBox : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }
	
	** Returns the 'name' attribute.
	Str name() {
		getAttr("name") ?: ""
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

	** Gets and sets the 'checked' attribute.
	Bool checked {
		get { getAttr("checked") != null }
		set { setAttr("checked", it ? "checked" : null) }
	}

	** Verify the checkbox is checked. 
	Void verifyChecked() {
		verifyTrue(checked, "Checkbox is NOT checked")	
	}

	** Verify the checkbox is NOT checked. 
	Void verifyNotChecked() {
		verifyTrue(!checked, "Checkbox IS checked")
	}

	@NoDoc
	override protected XElem findElem() {
		elem := Attr(super.findElem)
		if (elem.name != "input" || elem["type"]?.lower != "checkbox")
			fail("Element is NOT a checkbox: ", false)
		return elem.elem
	}
}