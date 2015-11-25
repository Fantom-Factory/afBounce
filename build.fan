using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing BedSheet applications"
		version = Version("1.1.0")

		meta = [
			"proj.name"		: "Bounce",
			"repo.tags"		: "testing, web",
			"repo.public"	: "false"
		]

		depends = [
			"sys        1.0",
			"concurrent 1.0",
			"wisp       1.0",
			"web        1.0",
			"inet       1.0",
			"xml        1.0",

			// ---- Core ------------------------
			"afConcurrent 1.0.12 - 1.0", 
			"afIoc        3.0.0  - 3.0", 
			"afIocConfig  1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.0  - 1.5",
			"afButter     1.1.10 - 1.1",
			"afSizzle     1.0.2  - 1.0",

			// ---- Other -------------------------
			"afHtmlParser 0+"
		]
		
		srcDirs = [`test/`, `test/web-tests/`, `test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]
	}
}
