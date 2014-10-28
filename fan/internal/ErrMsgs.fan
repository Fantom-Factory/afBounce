
internal const class ErrMsgs {

	static Str typeNotFound(Type type) {
		stripSys("Could not find type ${type.qname}")
	}

	static Str methodGetOrPostOnly(Str method) {
		"Form method attribute should be GET or POST only: ${method}"
	}
	
	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
