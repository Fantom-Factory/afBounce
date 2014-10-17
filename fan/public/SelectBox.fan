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
	** Returns 'null' if a match could not be found.
	Option? optionByValue(Obj value) {
		options.find { it.value.equalsIgnoreCase(value.toStr.trim) }
	}

	** Return the option element with the given text (display value).
	** Returns 'null' if a match could not be found.
	Option? optionByText(Obj value) {
		options.find { it.text.equalsIgnoreCase(value.toStr.trim) }
	}

	** Return the currently checked option element.
	** Returns 'null' if no option is checked.
	Option? checked() {
		// ensure we only bring back an option for the ONE selectbox
		findElem
		option := find("option[checked]").toOption
		return option.exists ? option : null
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
				SizzleDoc(findSelect).select("option").each |option| {
					Attr(option)["checked"] = null
				}
			}
			setAttr("checked", it ? "checked" : null) 
		}
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

	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("option"))
			fail("Element is NOT an <option>", false)
		return elem
	}

	private XElem findSelect(XElem elem := findElem) {
		if (elem.name.equalsIgnoreCase("select"))
			return elem
		if (elem.parent != null)
			return findSelect(elem.parent)
		return fail("Could not find enclosing Select element: ", true)
	}
}
