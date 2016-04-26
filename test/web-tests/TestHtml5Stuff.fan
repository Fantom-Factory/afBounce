
internal class TestHtml5Stuff : WebTest {
	
	Void testFormAttrsAreOverridden() {
		client.get(`/formTest`)
		
		// test formaction and formmethod attributes
		res := SubmitButton("#submitAlt").click
		
		map := (Map) res.body.str.in.readObj
		verifyEq(map["submit"], "dex")
		
		verifyEq(client.lastRequest.method, "GET")
		verifyEq(client.lastRequest.url.pathOnly, `/printFormAlt`)
	}

	Void testNonParentForm() {
		// test form attributes
		
		client.get(`/formTest`)		
		res := SubmitButton("#submitAlt2").click
		map := (Map) res.body.str.in.readObj
		verifyEq(map["submit"], "dex2")

		client.get(`/formTest`)		
		res = SubmitButton("#submitAlt3").click
		map = (Map) res.body.str.in.readObj
		verifyEq(map["submit"], "")

		verifyErr(Type.find("sys::TestErr")) {
			client.get(`/formTest`)
			SubmitButton("#submitAlt4").click
		}
	}
}
