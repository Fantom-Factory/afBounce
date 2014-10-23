
internal const class ErrMsgs {

	static Str typeNotFound(Type type) {
		stripSys("Could not find type ${type.qname}")
	}
	
	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}

}
