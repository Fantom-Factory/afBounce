
internal class TestHtml5Stuff : WebTest {
	
	Void testFormAttrsAreOverridden() {
		client.get(`/formTest`)
		
		// test formaction and formmethod attributes
		res := SubmitButton("#submitAlt").click
		
		map := (Map) res.asStr.in.readObj
		verifyEq(map["submit"], "dex")
		
		echo(client.lastRequest.method)
		echo(client.lastRequest.uri)
		
		verifyEq(client.lastRequest.method, "WEIRD")
		verifyEq(client.lastRequest.uri, `/printFormAlt`)
	}
	
}
