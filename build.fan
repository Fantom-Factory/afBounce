using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing Bed applications!"
		version = Version("1.0.1")

		meta = [
			"proj.name"		: "Bounce",
			"tags"			: "testing, web",
			"repo.private"	: "true",
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"wisp 1.0",
			"web 1.0",
			"inet 1.0",
			"xml 1.0",
			
			"afConcurrent 1.0.0+", 
			"afIoc 1.6.0+", 
			"afIocConfig 1.0.4+", 
			"afBedSheet 1.3.6+",
			"afButter 0.0.6+",
			"afSizzle 1.0.0+"
		]
		
		srcDirs = [`test/`, `test/web-tests/`, `test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
