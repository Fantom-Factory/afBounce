using xml

internal class TestElement : Test {
	
	Void testTextSimple() {
		xml := XElem("div") {
			XText("Hello!"),
		}
		elem := BounceNode([xml])
		
		verifyEq(elem.text, 		"Hello!")
		verifyEq(elem.markup, 		"<div>Hello!</div>")
		verifyEq(elem.childMarkup,	"Hello!")
	}

	Void testTextNested() {
		elem := BounceNode([XParser(
			"<div>Hello
			 	<span> Mum</span>
			 !</div>".in).parseDoc.root])
		verifyEq(elem.text, 		"Hello\n\t Mum\n!")
		verifyEq(elem.markup,		"<div>Hello\n\t<span> Mum</span>\n!</div>")
		verifyEq(elem.childMarkup,	"Hello\n\t<span> Mum</span>\n!")
	}
	
	Void testNotFoundErrSingle() {
		elem := BounceNode([,])
		verifyErr(Test#.pod.type("TestErr")) {
			elem.text
		}		
	}

	Void testNotFoundErrMultiple() {
		xml := XElem("div") {
			XText("Hello!"),
		}
		elem := BounceNode([xml, xml])
		verifyErr(Test#.pod.type("TestErr")) {
			elem.text
		}
	}

}
