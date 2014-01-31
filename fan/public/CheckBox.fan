using xml
using afButter

** (HTML Element) 
const class CheckBox : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }
	
	Str name() {
		getAttr("name") ?: ""
	}

	Bool checked {
		get { getAttr("checked") == null }
		set { setAttr("checked", it ? "checked" : null) }
	}

	Bool enabled {
		get { getAttr("disabled") == null }
		set { setAttr("disabled", it ? null : "disabled") }
	}

	Bool disabled {
		get { getAttr("disabled") != null }
		set { setAttr("disabled", it ? "disabled" : null) }
	}
	
	
	// TODO: verify Checked & NotChecked
	
	ButterResponse submitForm() {
		super.submitEnclosingForm
	}
	
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("input") && !(elem.attr("type", false)?.val?.equalsIgnoreCase("checkbox") ?: false))
			fail("Element is NOT a checkbox")
		return elem
	}
}