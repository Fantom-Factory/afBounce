using build

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing Bed applications!"
		version = Version("1.0.1")

		meta = [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Bounce",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afBounce",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afbounce",
			"license.name"	: "The MIT Licence",	
			"repo.private"	: "true",
			
			"tags"			: "testing, web"
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
		resDirs = [`licence.txt`, `doc/`]

		docApi = true
		docSrc = true
	}

	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// see "stripTest" in `/etc/build/config.props` to exclude test src & res dirs
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
