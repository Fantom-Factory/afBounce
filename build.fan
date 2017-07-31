using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A headless browser for testing web sites and BedSheet applications"
		version = Version("1.1.6")

		meta = [
			"pod.dis"		: "Bounce",
			"repo.tags"		: "testing, web",
			"repo.public"	: "true"
		]

		depends = [
			"sys        1.0.69 - 1.0",
			"concurrent 1.0.69 - 1.0",
			"wisp       1.0.69 - 1.0",
			"web        1.0.69 - 1.0",
			"inet       1.0.69 - 1.0",
			"xml        1.0.69 - 1.0",

			// ---- Core ------------------------
			"afConcurrent 1.0.18 - 1.0", 
			"afIoc        3.0.4  - 3.0", 
			"afIocConfig  1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.6  - 1.5",
			"afButter     1.2.6  - 1.2",
			"afSizzle     1.0.2  - 1.0",

			// ---- Other -------------------------
			"afHtmlParser 0.1.2  - 0.1"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`, `test/unit-tests/`, `test/web-tests/`]
		resDirs = [`doc/`]
	}
}
