
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
			switch (elementName) {
				case "input":
					if (getAttr("type") == "checkbox")
						return toCheckBox.checked.toStr
					else
						return getAttr("value")
				case "textarea":
				    return toTextBox.value
				case "select":
				    return toSelectBox.checked.value
				case "option":
				    return toOption.value
				default:
				    return fail("Element is NOT a form input: ", false)
			}
		}
		set {
			switch (elementName) {
				case "input":
					if (getAttr("type") == "checkbox")
						toCheckBox.checked = it.toBool
					else
						setAttr("value", it)
				case "textarea":
				    toTextBox.value = it
				case "select":
				    toSelectBox.optionByValue(it).checked = true
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
