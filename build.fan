using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing BedSheet applications!"
		version = Version("1.0.16")

		meta = [
			"proj.name"		: "Bounce",
			"tags"			: "testing, web",
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"wisp 1.0",
			"web 1.0",
			"inet 1.0",
			"xml 1.0",

			// ---- Core ------------------------
			"afConcurrent 1.0.6+", 
			"afIoc 2.0.0+", 
			"afIocConfig 1.0.16+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.16+",
			"afButter 1.0.2+",
			"afSizzle 1.0.0+",

			// ---- Other -------------------------
			"afHtmlParser 0+"
		]
		
		srcDirs = [`test/`, `test/web-tests/`, `test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [,]
	}
}
