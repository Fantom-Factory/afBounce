using xml
using afButter

** (HTML Element) 
const class Button : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

	Str? name() {
		getAttr("name")
	}

	Uri? action() {
		getAttr("action")?.toUri
	}

	Str value {
		get { getAttr("value") }
		set { setAttr("value", it) }
	}

	Bool enabled {
		get { getAttr("disabled") == null }
		set { setAttr("disabled", it ? null : "disabled") }
	}

	Bool disabled {
		get { getAttr("disabled") != null }
		set { setAttr("disabled", it ? "disabled" : null) }
	}
	
	ButterResponse click() {
		submitForm
	}

	ButterResponse submitForm() {
		values := [:]
		if (name != null)
			values[name] = value
		return super.submitEnclosingForm(values, action)
	}
	
	override protected XElem findElem() {
		elem := super.findElem
		name := elem.name.lower
		if (name == "button")
			return elem
		if (name == "input" && (elem.attr("type", false)?.val?.equalsIgnoreCase("submit") ?: false))
			return elem
		return fail("Element is NOT a button")
	}
}