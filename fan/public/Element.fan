using afSizzle
using afButter
using xml

** Represents a number of HTML elements as returned from `BedClient` select CSS methods.
const class Element {
	
	private const ElemFinder finder
	
	static new fromCss(Str cssSelector) {
		Element(FindFromBedClient(cssSelector)) 
	}
	
	@NoDoc
	new fromFinder(ElemFinder elemFinder) {
		this.finder = elemFinder 
	}

	
	
	// ---- Standard Methods -------------------------------------------------------------------------------------------
	
	** Returns the 'id' as declared by the element. Returns 'null' if the element does not have an 'id' attribute.
	Str? id() {
		getAttr("id")
	}

	** Returns the 'class' attribute as declared by the element, otherwise null.
	Str? classs() {
		getAttr("class")
	}
	
	** Returns 'true' if the element contains the given value. 
	** 
	** The match is done on a whitespace split of the class attribute and is case insensitive.
	Bool hasClass(Str value) {
		getAttr("class")?.lower?.split?.contains(value.trim.lower) ?: false
	}
	
	** Returns 'true' if this element exists.
	Bool exists() {
		!findElems.isEmpty
	}
	
	** Returns the text content of this element and it's child elements.
	Str text() {
		getText(findElem)
	}

	** Returns the markup generated by this node, including the element itself. 
	Str html() {
		getHtml(findElem)
	}

	** Returns the markup generated by the children of this node. 
	Str innerHtml() {
		getInnerHtml(findElem)
	}

	** Returns the value of the named attribute. Returns 'null' if it does not exist.
	** Usage:
	**   value := element["value"]
	@Operator
	Str? getAttr(Str name) {
		findElem.attr(name, false)?.val
	}

	** Returns the element of the current selection at the specified index. Use -1 to select from the end of the list.
	** Usage:
	**   value := element[-2]
	** 
	** Note this method is *safe* and does NOT throw an Err should the index be out of bounds. 
	** Instead use 'verifyDoesNotExist()'.
	** 
	** Also Note that this returns different results to the CSS selector ':nth-child'.  
	@Operator
	This getAtIndex(Int index) {
		newElementAtIndex(index)
	}

	** Returns the number of elements found by the selector
	Int size() {
		findElems.size
	}

	** Finds elements *inside* this element.
	Element find(Str cssSelector) {
		newElementFromCss(cssSelector)		
	}
	
	** Return all elements as a list.
	Element[] list() {
		findElems.map |elem, i| { newElementAtIndex(i) }
	}
	
	** Return the underlying 'XElem' objects
	XElem[] xelems() {
		findElems
	}
	
	
	
	// ---- Verify Methods ---------------------------------------------------------------------------------------------
	
	// Verify that at least one element is selected from the document, otherwise throw a test failure exception.
	Void verifyExists() {
		verifyTrue(exists, "CSS does NOT exist: ")
	}
	
	// Verify that the current selection heralds no elements, otherwise throw a test failure exception.
	Void verifyDoesNotExist() {
		verifyTrue(!exists, "CSS DOES exist: ")
	}
	
	// Verify that the given text matches the text of the element. The match is case insensitive. 
	Void verifyTextEq(Obj expected) {
		verifyEq(text, expected)
	}

	// Verify that the element text contains the given str. The match is case insensitive. 
	Void verifyTextContains(Obj contains) {
		verifyTrue(text.trim.lower.contains(contains.toStr.trim.lower), "Text does NOT contain '${contains}': ")
	}
	
	// Verify that the element has the given attribute. 
	Void verifyAttrEq(Str attrName, Obj expected) {
		verifyTrue(findElem.attr(attrName, false) != null, "Attribute '${attrName}' does NOT exist: ")
		verifyEq(findElem.attr(attrName).val, expected)
	}
	
	// Verify that the current selection has the given size. 
	Void verifySizeEq(Int expectedSize) {
		verifyEq(size.toStr, expectedSize)
	}

	// Verify that the current selection has the given size. 
	Void verifyClassContains(Obj expected) {
		attrName := "class"
		verifyTrue(findElem.attr(attrName, false) != null, "Attribute '${attrName}' does NOT exist: ")
		verifyTrue(hasClass(expected.toStr), "Class attribute does NOT exist: ")
	}

	
	
	// ---- Conversion Methods -----------------------------------------------------------------------------------------
	
	CheckBox toCheckBox() {
		CheckBox(finder)
	}
	
	Link toLink() {
		Link(finder)
	}
	
	SelectBox toSelectBox() {
		SelectBox(finder)
	}

	TextBox toTextBox() {
		TextBox(finder)
	}
	
	
	
	// ---- Common Verify Methods --------------------------------------------------------------------------------------

	@NoDoc
	protected Void verifyTrue(Bool condition, Str msg) {
		Verify().verify(condition, msg + toStr)
	}
	
	@NoDoc
	protected Void verifyEq(Str actual, Obj expected) {
		if (actual.trim.lower != expected.toStr.trim.lower)
			Verify().verifyEq(actual, expected)
	}

	@NoDoc
	protected Void fail(Str msg) {
		Verify().fail(msg + toStr)
	}
	

	
	// ---- Finder Methods ---------------------------------------------------------------------------------------------

	@NoDoc
	virtual protected XElem findElem() {
		elems := findElems
		if (elems.size != 1)
			fail("CSS does not exist: ")
		return elems.first
	}

	@NoDoc
	virtual protected XElem[] findElems() {
		finder.findElems
	}

	

	// ---- Private Methods --------------------------------------------------------------------------------------------

	virtual protected ButterResponse submitForm() {
		// TODO: submitForm
		BedClient.getThreadedClient.postForm(``, [:])
	}

	** Sets the attribute. A value of 'null' removes it.
	protected Void setAttr(Str name, Str? value, XElem elem := findElem) {
		attr := elem.attr(name, false)
		if (attr != null)
			elem.removeAttr(attr)
		if (value != null) 
			elem.addAttr(name, value)
	}

	private Element newElementAtIndex(Int index) {
		Element(finder.clone(FindAtIndex(index)))
	}

	private Element newElementFromCss(Str cssSelector) {
		Element(finder.clone(FindFromCss(cssSelector)))
	}
	
	private Str getHtml(XElem elem) {
		elem.writeToStr
	}

	private Str getInnerHtml(XElem elem) {
		elem.children.map |XNode node->Str| { node.writeToStr }.join
	}

	private Str getText(XNode node) {
		if (node is XText)
			return ((XText) node).val
		if (node is XElem)
			return ((XElem) node).children.map { getText(it) }.join
		return Str.defVal
	}

	override Str toStr() {
		return finder.toStr + "\n" + findElems.map { getHtml(it) }.join("\n")
	}
}

internal class Verify : Test {}
