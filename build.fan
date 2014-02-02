using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing Bed applications!"
		version = Version("0.0.7")

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
			
			"afIoc 1.5.2+", 
			"afIocConfig 1.0.2+", 
			"afBedSheet 1.3.0+",
			"afButter 0.0.4+",
			"afSizzle 1.0.0+"
		]
		
		srcDirs = [`test/`, `test/web-tests/`, `test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}

	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
		resDirs = resDirs.exclude { it.toStr.startsWith("res/test/") }
		
		super.compile
		
		// copy src to %FAN_HOME% for F4 debugging
		log.indent
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)		
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}
}
