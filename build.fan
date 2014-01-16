using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing Bed applications!"
		version = Version("0.0.1")

		meta	= [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Bounce",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afBounce",
			"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afbounce",
			"license.name"	: "BSD 2-Clause License",	
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"wisp 1.0",
			"web 1.0",
			"inet 1.0",
			"xml 1.0",
			"afIoc 1.5+", 
			"afBedSheet 1.2.4.1+",
			"afButter 0+",
			"afSizzle 0+"
		]
		
		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true

	}
}
