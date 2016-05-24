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
	** Returns 'null' if the value has not been set.
	Str? value {
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
	
	** Returns all radio buttons in the containing form that have the same name as this one.
	RadioButton[] allButtons() {
		name := findElems.first.get("name", false) 
		return Element("#${formId} input[name=${name}]").list.map { it.toRadioButton }
	}
	
	** Return the radio button with the given value.
	** Returns 'null' if a match could not be found.
	RadioButton? findByValue(Obj value) {
		allButtons.find { it.value == value.toStr }
	}

	** Return the currently checked radio button.
	** Returns 'null' if no button is checked.
	RadioButton? checkedButton() {
		allButtons.find { it.checked }
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
		if (Attr(elem).name != "input" || Attr(elem)["type"]?.lower != "radio")
			fail("Element is NOT a submit button: ", false)
		return elem
	}
	
	private Str formId() {
		radioId := findElems.first.get("id", false) ?: throw Err("Need to calculate a unique CSS path - it would help if you gave the Input an ID!\n" + toStr)
		formId  := Element("#${radioId}").findForm.get("id", false) ?: throw Err("Need to calculate a unique CSS path - it would help if you gave the form an ID!\n" + toStr)
		return formId
	}
}