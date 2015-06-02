using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing BedSheet applications"
		version = Version("1.0.20")

		meta = [
			"proj.name"		: "Bounce",
			"repo.tags"		: "testing, web",
			"repo.public"	: "true"
		]

		depends = [
			"sys        1.0",
			"concurrent 1.0",
			"wisp       1.0",
			"web        1.0",
			"inet       1.0",
			"xml        1.0",

			// ---- Core ------------------------
			"afConcurrent 1.0.6  - 1.0", 
			"afIoc        2.0.6  - 2.0", 
			"afIocConfig  1.0.16 - 1.0",
			
			// ---- Web -------------------------
			"afBedSheet   1.4.8  - 1.4",
			"afButter     1.1.2  - 1.1",
			"afSizzle     1.0.2  - 1.0",

			// ---- Other -------------------------
			"afHtmlParser 0+"
		]
		
		srcDirs = [`test/`, `test/web-tests/`, `test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]
	}
}
