using xml

internal class TestElement : UnitTest {
	
	Void testTextSimple() {
		xml := XElem("div") {
			XText("Hello!"),
		}
		elem := Element(FindUnsafeRefs([xml]))
		
		verifyEq(elem.text, 		"Hello!")
		verifyEq(elem.html, 		"<div>Hello!</div>")
		verifyEq(elem.innerHtml,	"Hello!")
	}

	Void testTextNested() {
		elem := Element(FindUnsafeRefs([XParser(
			"<div>Hello
			 	<span> Mum</span>
			 !</div>".in).parseDoc.root]))
		verifyEq(elem.text, 		"Hello\n\t Mum\n!")
		verifyEq(elem.html,			"<div>Hello\n\t<span> Mum</span>\n!</div>")
		verifyEq(elem.innerHtml,	"Hello\n\t<span> Mum</span>\n!")
	}
	
	Void testNotFoundErrSingle() {
		elem := Element(FindUnsafeRefs([,]))
		verifyErr(Test#.pod.type("TestErr")) {
			elem.text
		}		
	}

	Void testNotFoundErrMultiple() {
		xml := XElem("div") {
			XText("Hello!"),
		}
		elem := Element(FindUnsafeRefs([xml, xml]))
		verifyErr(Test#.pod.type("TestErr")) {
			elem.text
		}
	}
}
