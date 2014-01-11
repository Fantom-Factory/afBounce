using afButter
using afSizzle
using xml

class SizzleMiddleware : ButterMiddleware {
	
	SizzleDoc sizzleDoc {
		get { getSizzleDoc() }
		private set { }
	}

	XElem[] select(Str cssSelector) {
		sizzleDoc.select(cssSelector)
	}

	private SizzleDoc?		doc
	private ButterResponse? res

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		this.res = null
		this.doc = null
		this.res = butter.sendRequest(req)
		return res
	}

	private SizzleDoc getSizzleDoc() {
		if (doc != null)
			return doc
		if (matchesType(res.headers.contentType, ["text/html", "application/xhtml+xml", "application/xml", "text/xml"])) {
			doc = SizzleDoc(res.asStr)
			return doc
		}
		throw Err("Wrong content type: ${res.headers.contentType}")
	}

	private Bool matchesType(MimeType? mimeType, Str[] types) {
		if (mimeType == null)
			return false
		type := "${mimeType.mediaType}/${mimeType.subType}".lower
		return types.any { it == type }
	}
}

mixin SizzleDish : ButterDish {
	
	SizzleDoc sizzleDoc() {
		sizzle.sizzleDoc
	}

	XElem[] select(Str cssSelector) {
		sizzle.select(cssSelector)
	}
	
	private SizzleMiddleware sizzle() {
		findMiddleware(SizzleMiddleware#)
	}
}

