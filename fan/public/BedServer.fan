using concurrent::AtomicBool
using concurrent::AtomicRef
using afConcurrent::AtomicList
using afIoc::Registry
using afIoc::RegistryBuilder
using wisp::MemWispSessionStore
using wisp::WispSessionStore
using afBedSheet::BedSheetModule
using afBedSheet::BedSheetMetaData
using afBedSheet::BedSheetWebMod
using afButter::Butter
using afButter::HttpTerminator

** Initialises a Bed App without the overhead of starting the 'wisp' web server. 
** 
** 'BedServer' is a 'const' class so it may be used in multiple threads. Do this to create 'BedClients' in different
** threads to make concurrent calls - handy for load testing.
const class BedServer {
	private const static Log log := Utils.getLog(BedServer#)

	private const AtomicRef		reg			:= AtomicRef()
	private const AtomicBool	started		:= AtomicBool()
	private const AtomicRef		moduleName	:= AtomicRef()
	private const AtomicList	modules		:= AtomicList()

	** The 'afIoc' registry - read only.
	Registry registry {
		get { checkHasStarted; return reg.val }
		private set { reg.val = it }
	}

	** Create a instance of 'BedSheet' with the given qname of either a Pod or a Type. 
	new makeWithName(Str qname) {
		this.moduleName.val = qname
	}

	** Create a instance of 'BedSheet' with the given IoC module (usually your web app).
	new makeWithModule(Type iocModule) {
		this.moduleName.val = iocModule.qname
	}

	** Create a instance of 'BedSheet' with the given pod (usually your web app).
	new makeWithPod(Pod webApp) {
		this.moduleName.val = webApp.name
	}

	** Adds an extra (test) module, should you wish to override service behaviour.
	BedServer addModule(Type iocModule) {
		checkHasNotStarted
		this.modules.add(iocModule)
		return this
	}

	** Startup 'afBedSheet'
	BedServer startup() {
		checkHasNotStarted
		
		bob := BedSheetWebMod.createBob(moduleName.val, 0)		
		bob.addModules(modules.list)
		bob.options["bannerText"]	= "Alien-Factory BedServer v${typeof.pod.version}, IoC v${Registry#.pod.version}" 
		bob.options["appName"]		= "BedServer"
			
		registry = bob.build.startup
		started.val = true
		return this
	}

	** Shutdown 'afBedSheet'
	BedServer shutdown() {
		if (started.val)
			registry.shutdown
		reg.val = null
		started.val = false
		modules.clear
		return this
	}
	
	** Creates a pack of 'Butter' whose middleware ends with a BedTerminator which makes requests to the Bed app.  
	BedClient makeClient() {
		checkHasStarted
		return BedClient(Butter.churnOut(
			Butter.defaultStack
				.exclude { it.typeof == HttpTerminator# }
				.add(BedTerminator(this))
				.insert(0, SizzleMiddleware())
		))
	}

	// ---- Registry Methods ----
	
	** Helper method - tap into BedSheet's afIoc registry
	Obj serviceById(Str serviceId) {
		checkHasStarted
		return registry.serviceById(serviceId)
	}

	** Helper method - tap into BedSheet's afIoc registry
	Obj dependencyByType(Type dependencyType) {
		checkHasStarted
		return registry.dependencyByType(dependencyType)
	}

	** Helper method - tap into BedSheet's afIoc registry
	Obj autobuild(Type type, Obj?[] ctorArgs := Obj#.emptyList) {
		checkHasStarted
		return registry.autobuild(type, ctorArgs)
	}

	** Helper method - tap into BedSheet's afIoc registry
	Obj injectIntoFields(Obj service) {
		checkHasStarted
		return registry.injectIntoFields(service)
	}
	
	// ---- helper methods ----
	
	** as called by BedClients - if no reg then we must have been shutdown
	internal Void checkHasNotShutdown() {
		if (reg.val == null)
			throw Err("${BedServer#.name} has been shutdown!")
	}

	private Void checkHasStarted() {
		if (!started.val)
			throw Err("${BedServer#.name} has not yet started!")
	}

	private Void checkHasNotStarted() {
		if (started.val)
			throw Err("${BedServer#.name} has not already been started!")
	}
}
