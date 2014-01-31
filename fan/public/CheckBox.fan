using xml
using afButter

const class CheckBox : Element {
	
	@NoDoc
	new fromFinder(ElemFinder elemFinder) : super(elemFinder) { }
	
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
	
	override ButterResponse submitForm() {
		super.submitForm
	}
	
	override protected XElem findElem() {
		elem := super.findElem
		if (!elem.name.equalsIgnoreCase("input") && !(getAttr("type")?.equalsIgnoreCase("checkbox") ?: false))
			fail("Element is NOT a checkbox")
		return elem
	}
}