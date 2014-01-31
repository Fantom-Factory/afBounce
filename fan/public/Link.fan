using xml
using afButter

const class Link : Element {
	
	@NoDoc
	new fromFinder(ElemFinder elemFinder) : super(elemFinder) { }

	Str href() {
		getAttr("href")
	}
	
	ButterResponse click() {
		BedClient.getThreadedClient.get(href.toUri)
	}
	
	override ButterResponse submitForm() {
		super.submitForm
	}
}