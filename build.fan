using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing BedSheet applications, and an API for navigating web pages"
		version = Version("1.1.1")

		meta = [
			"proj.name"		: "Bounce",
			"repo.tags"		: "testing, web",
			"repo.public"	: "false"
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
			"afIoc        3.0.0  - 3.0", 
			"afIocConfig  1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.1  - 1.5",
			"afButter     1.2.1  - 1.2",
			"afSizzle     1.0.2  - 1.0",

			// ---- Other -------------------------
			"afHtmlParser 0.1.0  - 0.1"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`, `test/unit-tests/`, `test/web-tests/`]
		resDirs = [`doc/`]
	}
}
