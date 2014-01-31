using xml
using afSizzle

** All this so I can have a getAtIndex(n) method!
@NoDoc
abstract const class ElemFinder {
	const ElemFinder? finder
	abstract XElem[] findElems(XElem[]? elems := null)
	abstract ElemFinder clone(ElemFinder deepFinder)
}

internal const class FindFromBedClient : ElemFinder {
	const Str css
	const |->BedClient| bedClientFunc
	new make(|->BedClient| bedClientFunc, Str css, ElemFinder? finder := null) {
		this.bedClientFunc = bedClientFunc
		this.css = css
		this.finder = finder
	}
	override XElem[] findElems(XElem[]? elems := null) {
		found := bedClientFunc().selectCss(css)
		return finder?.findElems(found) ?: found
	}
	override ElemFinder clone(ElemFinder deepFinder) {
		FindFromBedClient(bedClientFunc, css, (finder == null) ? deepFinder : finder.clone(deepFinder))
	}
	override Str toStr() {
		css + (finder?.toStr ?: "")
	}
}

internal const class FindAtIndex : ElemFinder {
	const Int index
	new make(Int index, ElemFinder? finder := null) {
		this.index = index
		this.finder = finder
	}
	override XElem[] findElems(XElem[]? elems := null) {
		found := (index < elems.size) ? [elems[index]] : XElem#.emptyList
		return finder?.findElems(found) ?: found
	}
	override ElemFinder clone(ElemFinder deepFinder) {
		FindAtIndex(index, (finder == null) ? deepFinder : finder.clone(deepFinder))
	}
	override Str toStr() {
		"[$index]" + (finder?.toStr ?: "")
	}
}

internal const class FindFromCss : ElemFinder {
	const Str css
	new make(Str css, ElemFinder? finder := null) {
		this.css = css
		this.finder = finder
	}
	override XElem[] findElems(XElem[]? elems := null) {
		found := elems.map |elem -> XElem[]| {
			SizzleDoc(elem).select(css)
		}.flatten
		return finder?.findElems(found) ?: found
	}
	override ElemFinder clone(ElemFinder deepFinder) {
		FindFromCss(css, (finder == null) ? deepFinder : finder.clone(deepFinder))
	}
	override Str toStr() {
		css + (finder?.toStr ?: "")
	}
}

internal const class FindUnsafeRefs : ElemFinder {
	const Unsafe elems	// for testing only
	new make(XElem[] elems, ElemFinder? finder := null) {
		this.elems = Unsafe(elems)
		this.finder = finder
	}
	override XElem[] findElems(XElem[]? elems := null) {
		found := elems
		return finder?.findElems(found) ?: found
	}
	override ElemFinder clone(ElemFinder deepFinder) {
		FindUnsafeRefs(elems.val, (finder == null) ? deepFinder : finder.clone(deepFinder))
	}
	override Str toStr() {
		"XElem[] " + (finder?.toStr ?: "")
	}
}

