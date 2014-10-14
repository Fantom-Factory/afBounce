
internal class TestUrlEncoding : WebTest {

	Void testLink() {
		client.get(`/urlTest`)

		res := Link("a").click
		// check the %20 has been decoded
		verifyEq(res.asStr, "/printUrl/hello moto")
	}

	Void testSubmit() {
		client.get(`/urlTest`)

		res := SubmitButton("input").click
		// check the %20 has been decoded
		verifyEq(res.asStr, "/printUrl/wot ever")
	}

}
