using xml
using afButter
using afSizzle

** (HTML Element) Represents a form '<input>' of type 'radio'.
const class RadioButton : Element {

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

	** Gets and sets the 'checked' attribute. If setting to 'true', all other options are set to false. 
	Bool checked {
		get { getAttr("checked") != null }
		set { 
			if (it) {
				SizzleDoc(findForm).select("input[name=${name}]").each |radio| {
					Attr(radio)["checked"] = null
				}
			}
			setAttr("checked", it ? "checked" : null) 
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
	
	** Submits the enclosing form.
	ButterResponse submitForm() {
		super.submitEnclosingForm(findElem)
	}
	
	** Verify that the hidden element has the given value.
	Void verifyValueEq(Obj expected) {
		verifyEq(value, expected)	
	}

	** Verify the option is checked. 
	Void verifyChecked() {
		verifyTrue(checked, "Option is NOT checked: ")	
	}

	** Verify the option is NOT checked. 
	Void verifyNotChecked() {
		verifyTrue(!checked, "Option IS checked: ")
	}

	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (Attr(elem).name != "input" && Attr(elem)["type"]?.lower != "radio")
			return fail("Element is NOT a submit button: ", false)
		return elem
	}
}