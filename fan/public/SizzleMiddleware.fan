using afButter
using afSizzle::SizzleDoc
using afHtmlParser::HtmlParser
using xml::XElem

** Middleware that lets you make CSS selector queries against the HTTP response.
** 
** You need to make sure the 'ButterResponse' holds a well formed XML document else an 'XErr' is thrown. If rendering
** [Slim]`http://www.fantomfactory.org/pods/afSlim` templates then make sure it compiles XHTML documents (and not HTML):
** 
**   slim := Slim(TagStyle.xhtml) 
** 
** 'SizzleMiddleware' lazily parses the 'ButterResponse' into a 'SizzleDoc' so you can still make requests for non XML
** documents - just don't query them!  
class SizzleMiddleware : ButterMiddleware {
	
	** If 'true' (the default) then [HtmlParser]`http://www.fantomfactory.org/pods/afHtmlParser` is used to parse the response for HTML.
	** 
	** If 'false' then the standard Fantom XML parser is used. 
	Bool useHtmlParser	:= true
	
	** The 'SizzleDoc' associated with the last request.
	SizzleDoc sizzleDoc {
		get { getSizzleDoc() }
		private set { }
	}

	** Selects elements from the 'SizzleDoc'.
	XElem[] select(Str cssSelector) {
		sizzleDoc.select(cssSelector)
	}

	private Uri?			reqUri
	private SizzleDoc?		doc
	private ButterResponse? res
	private HtmlParser?		htmlParser

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		this.res = null
		this.doc = null
		this.reqUri = null
		this.res = butter.sendRequest(req)
		this.reqUri = req.url
		return res
	}

	private SizzleDoc getSizzleDoc() {
		if (res == null)
			throw Err("No requests have been made!")
		if (doc != null)
			return doc
		type := "HTML"
		try {
			// only use HtmlParser to parse HTML, XParser is much faster at XML
			if (useHtmlParser && res.headers.contentType.noParams.toStr.equalsIgnoreCase("text/html")) {
				if (htmlParser == null)
					htmlParser = HtmlParser()
				xml := htmlParser.parseDoc(res.body.str)
				doc = SizzleDoc(xml)
			}
			
			// if HtmlParser didn't work (or disabled) then try the usual way
			// it gives better error msgs anyway (for now).
			if (doc == null) {
				type = "XML"
				doc = SizzleDoc(res.body.str)		
			}
			
			return doc
		} catch (Err e) {
			Env.cur.err.printLine(res.body.str)
			throw ParseErr("Response at `${reqUri}` is NOT ${type} - $e.msg", e)
		}
	}

	private Bool matchesType(MimeType? mimeType, Str[] types) {
		if (mimeType == null)
			return false
		type := "${mimeType.mediaType}/${mimeType.subType}".lower
		return types.any { it == type }
	}
}

