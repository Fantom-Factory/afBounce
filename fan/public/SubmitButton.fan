using xml
using afButter

** (HTML Element) Represents a form '<input>' of type 'submit' or 'image'. 
** May also be used for '<button>' elements of type 'submit'.
const class SubmitButton : Element {
	
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
	ButterResponse click() {
		submitForm
	}

	@NoDoc
	override ButterResponse submitForm() {
		super.submitEnclosingForm(findElem)
	}

	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!isSubmitInput(elem) && !isSubmitButton(elem) && !isImageInput(elem))
			fail("Element is NOT a submit button: ", false)
		return elem
	}

	private Bool isSubmitInput(XElem elem) {
		Attr(elem).name == "input" && Attr(elem)["type"]?.lower == "submit"
	}

	private Bool isSubmitButton(XElem elem) {
		Attr(elem).name == "button" && Attr(elem)["type"]?.lower == "submit"
	}

	private Bool isImageInput(XElem elem) {
		Attr(elem).name == "input" && Attr(elem)["type"]?.lower == "image"		
	}
}