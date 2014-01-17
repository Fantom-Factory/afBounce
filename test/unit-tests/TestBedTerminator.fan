using afButter

internal class TestBedTerminator : BounceTest {
	
	Void testUrisMustNotHaveAuth() {
		mw := BedTerminator(BedServer(T_AppModule#))
		
		verifyErrTypeAndMsg(Err#, "Request URIs for Bed App testing should only be a path, e.g. `/index` vs `http://www.alienfactory.co.uk/dude`") {
			mw.sendRequest(Butter.churnOut, ButterRequest(`http://www.alienfactory.co.uk/dude`))
		}
	}

	Void testUrisMustStartWithSlash() {
		mw := BedTerminator(BedServer(T_AppModule#))
		
		verifyErrTypeAndMsg(Err#, "Request URIs for Bed App testing should start with a slash, e.g. `/index` vs `index`") {
			mw.sendRequest(Butter.churnOut, ButterRequest(`index`))
		}
	}

	Void testCanShutdownWithoutError() {
		mw := BedTerminator(BedServer(T_AppModule#))
		mw.shutdown
	}
}
