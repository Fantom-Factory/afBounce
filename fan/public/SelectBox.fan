using xml
using afButter
using afSizzle

** (HTML Element) Represents a form '<select>' element.
const class SelectBox : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }
	
	** Returns the 'name' attribute.
	Str name() {
		getAttr("name") ?: ""
	}

	** Return all option elements under this select.
	Option[] options() {
		// ensure we only bring back options for the ONE selectbox
		findElem
		return find("option").list.map { it.toOption }
	}

	** Return the option element with the given value.
	Option? optionByValue(Obj value) {
		options.find { it.value.equalsIgnoreCase(value.toStr.trim) }
	}

	** Return the option element with the given text (display value).
	Option? optionByText(Obj value) {
		options.find { it.text.equalsIgnoreCase(value.toStr.trim) }
	}

	** Return the currently checked option element.
	Option checked() {
		// ensure we only bring back an option for the ONE selectbox
		findElem
		return find("option[checked]").toOption
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
	
	** Submits the enclosing form, complete with this button's value.
	ButterResponse submitForm() {
		super.submitEnclosingForm
	}
	
	** Verify that the value of the checked option is equal to the given 
	Void verifyCheckedValueEq(Obj expected) {
		verifyEq(checked.value, expected)	
	}

	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("select"))
			fail("Element is NOT a <select>", false)
		return elem
	}
}

** (HTML Element) Represents a select '<option>' element. 
const class Option : Element {

	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

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
				SizzleDoc(findSelect).select("option").each |option| {
					Attr(option)["checked"] = null
				}
			}
			setAttr("checked", it ? "checked" : null) 
		}
	}

	** Submits the enclosing form to the Bed App.
	ButterResponse submitForm() {
		super.submitEnclosingForm
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

	private XElem findSelect(XElem elem := findElem) {
		if (elem.name.equalsIgnoreCase("select"))
			return elem
		if (elem.parent != null)
			return findSelect(elem.parent)
		return fail("Could not find enclosing Select element: ", true)
	}
}
