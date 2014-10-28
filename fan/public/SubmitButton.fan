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
		if (!isSubmit(elem))
			fail("Element is NOT a submit button: ", false)
		return elem
	}
	
	internal Bool isSubmit(XElem elem) {
		attr := Attr(elem)
		return isSubmitInput(attr) || isSubmitButton(attr) || isImageInput(attr)		
	}

	private Bool isSubmitInput(Attr elem) {
		elem.name == "input" && elem["type"]?.lower == "submit"
	}

	private Bool isSubmitButton(Attr elem) {
		elem.name == "button" && elem["type"]?.lower == "submit"
	}

	private Bool isImageInput(Attr elem) {
		elem.name == "input" && elem["type"]?.lower == "image"		
	}
}