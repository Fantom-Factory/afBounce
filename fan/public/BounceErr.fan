
** As thrown by Bounce.
const class BounceErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
