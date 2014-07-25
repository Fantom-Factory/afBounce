using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing BedSheet applications!"
		version = Version("1.0.10")

		meta = [
			"proj.name"		: "Bounce",
			"tags"			: "testing, web",
			"repo.private"	: "false",
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"wisp 1.0",
			"web 1.0",
			"inet 1.0",
			"xml 1.0",

			"afConcurrent 1.0.6+", 
			"afIoc 1.7.2+", 
			"afIocConfig 1.0.10+", 
			"afBedSheet 1.3.12+",
			"afButter 1.0.2+",
			"afSizzle 1.0.0+"
		]
		
		srcDirs = [`test/`, `test/web-tests/`, `test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [,]
	}
}
