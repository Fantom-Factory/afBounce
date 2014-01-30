using xml
class TextBox : Element {
	
	new make(Str cssSelector) : super(cssSelector) { }
	
	protected new makeInternal(XElem[] elems, Str css := "", Int? index := null) : super(elems, css, index) { }

}
