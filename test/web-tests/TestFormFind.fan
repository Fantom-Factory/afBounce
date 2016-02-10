
internal class TestFormFind : WebTest {
	
	Void testCanNotFindForm() {
		client.get(`/formTest`)

		// I want a test fail, rather than a sys::CastErr: java.lang.ClassCastException: fan.xml.XDoc cannot be cast to fan.xml.XElem		
		verifyErr(Type.find("sys::TestErr")) {
			FormInput("#formless").submitForm
		}
	}
}

