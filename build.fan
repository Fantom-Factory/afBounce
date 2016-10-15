using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A headless browser for testing web sites and BedSheet applications"
		version = Version("1.1.4")

		meta = [
			"pod.displayName"	: "Bounce",
			"repo.tags"			: "testing, web",
			"repo.public"		: "true"
		]

		depends = [
			"sys        1.0.68 - 1.0",
			"concurrent 1.0.68 - 1.0",
			"wisp       1.0.68 - 1.0",
			"web        1.0.68 - 1.0",
			"inet       1.0.68 - 1.0",
			"xml        1.0.68 - 1.0",

			// ---- Core ------------------------
			"afConcurrent 1.0.12 - 1.0", 
			"afIoc        3.0.4  - 3.0", 
			"afIocConfig  1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.2  - 1.5",
			"afButter     1.2.2  - 1.2",
			"afSizzle     1.0.2  - 1.0",

			// ---- Other -------------------------
			"afHtmlParser 0.1.0  - 0.1"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`, `test/unit-tests/`, `test/web-tests/`]
		resDirs = [`doc/`]
	}
}
