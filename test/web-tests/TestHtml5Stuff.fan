
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
		client.get(`/formTest`)
		
		// test formaction and formmethod attributes
		res := SubmitButton("#submitAlt2").click
		
		map := (Map) res.body.str.in.readObj
		verifyEq(map["submit"], "dex2")
	}
}
