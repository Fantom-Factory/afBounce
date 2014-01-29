using xml
using afSizzle

internal class BounceNode : Element {
	
	override 	
	internal XElem[]	elems
	private Str			css
	private Int?		index
	
	new make(XElem[] elems, Str css := "", Int? index := null) {
		indx := (index == null) ? Str.defVal : " at [${index}]"
		this.elems 	= elems
		this.css 	= css + indx
		this.index	= index
	}

	override Element[] list() {
		elems.map |elem, i| { BounceNode([elem], css, (index?:0) + i) }
	}

	override Element find(Str cssSelector) {
		elems := SizzleDoc(findElem).select(cssSelector)
		return BounceNode(elems, css + " " + cssSelector)
	}
	
	override internal This newElement(XElem elem, Int index) {
		BounceNode([elem], css, index)
	}
	
	override internal Void verifyTrue(Bool condition, Str msg) {
		Verify().verify(condition, msg + toStr)
	}
	
	override internal Void verifyEq(Str actual, Obj expected) {
		if (actual.trim.lower != expected.toStr.trim.lower)
			Verify().verifyEq(actual, expected)
	}

	override internal Void fail(Str msg) {
		Verify().fail(msg + toStr)
	}
	
	override Str toStr() {
		return css + "\n" + elems.map { getChildMarkup(it) }.join("\n")
	}
}

internal class Verify : Test {}