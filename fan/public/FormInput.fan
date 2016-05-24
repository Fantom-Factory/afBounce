
** (HTML Element) Gives a consistent means to get and set the value of *any* form field.  
const class FormInput : Element {
	
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
		get {
			// special handling for radio buttons which have multiple elements with the same name attr
			elem := findElems.first
			if (elem.name == "input" && elem.get("type", false) == "radio")
				return toRadioButton.checkedButton?.value
			
			switch (elementName) {
				case "input":
					switch (getAttr("type")) {
						case "checkbox":
							return toCheckBox.checked.toStr
						default:
							return getAttr("value")
					}
				case "textarea":
				    return toTextBox.value
				case "select":
				    return toSelectBox.selected?.value ?: null
				case "option":
				    return toOption.value
				default:
				    return fail("Element is NOT a form input: ", false)
			}
		}
		set {
			// special handling for radio buttons which have multiple elements with the same name attr
			elem := findElems.first
			if (elem.name == "input" && elem.get("type", false) == "radio")
				return toRadioButton.findByValue(it).checked = true

			switch (elementName) {
				case "input":
					switch (getAttr("type")) {
						case "checkbox":
							toCheckBox.checked = it.toBool
						default:
							setAttr("value", it)
					}
				case "textarea":
				    toTextBox.value = it
				case "select":
					if (toSelectBox.optionByValue(it) == null)
						fail("There is no <option> with the value: $it\n", false)						
				    toSelectBox.optionByValue(it).selected = true
				case "option":
				    toOption.value = it
				default:
				    fail("Element is NOT a form input: ", false)
			}			
		}
	}
	
	** Verify that the form field has the given value.
	Void verifyValueEq(Obj expected) {
		verifyEq(value, expected)
	}
}
