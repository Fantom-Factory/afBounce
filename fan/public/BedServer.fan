using concurrent::AtomicBool
using concurrent::AtomicRef
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
** 
const class BedServer {
	private const static Log log := Utils.getLog(BedServer#)

	private const AtomicRef		reg			:= AtomicRef()
	private const AtomicBool	started		:= AtomicBool()
	private const AtomicRef		modules		:= AtomicRef(Type#.emptyList)
	private const AtomicRef		moduleDeps	:= AtomicRef(Pod#.emptyList)
	private const AtomicRef		bsMeta		:= AtomicRef()

	** The 'afIoc' registry - read only.
	Registry registry {
		get { checkHasStarted; return reg.val }
		private set { reg.val = it }
	}

	** Create a instance of 'afBedSheet' with the given afIoc module (usually your web app)
	new makeWithModule(Type? iocModule := null) {
		addModulesFromDependencies(BedSheetModule#.pod)
		if (iocModule != null)
			addModule(iocModule)
		
		bsMeta.val = BedSheetMetaDataImpl(iocModule?.pod, iocModule, [:])
	}

	** Create a instance of 'afBedSheet' with afIoc dependencies from the given pod (usually your web app)
	new makeWithPod(Pod webApp) {
		addModulesFromDependencies(webApp)
		addModule(BedSheetModule#)

		// TODO: BedSheet 1.2.6
		mod := BedSheetWebMod#.method("findModFromPod").call(webApp)
		bsMeta.val = BedSheetMetaDataImpl(webApp, mod, [:])
	}

	** Add extra (test) modules should you wish to override behaviour in your tests
	BedServer addModule(Type iocModule) {
		checkHasNotStarted
		mods := (Type[]) modules.val
		modules.val = mods.rw.add(iocModule).toImmutable
		return this
	}

	BedServer addModulesFromDependencies(Pod dependency) {
		checkHasNotStarted
		deps := (Pod[]) moduleDeps.val
		moduleDeps.val = deps.rw.add(dependency).toImmutable
		return this
	}

	** Startup 'afBedSheet'
	BedServer startup() {
		checkHasNotStarted
		bannerText := "Alien-Factory BedServer v${typeof.pod.version}, IoC v${Registry#.pod.version}"
		
		bob := RegistryBuilder()
		
		((Pod[]) moduleDeps.val).each |pod| {
			bob.addModulesFromDependencies(pod)			
		}
		
		mods := (Type[]) modules.val
		bob.addModules(mods)

		bedSheetMetaData := bsMeta.val		
		registry = bob.build([
			"bannerText"					: bannerText, 
			"bedSheetMetaData"				: bedSheetMetaData, 
			"suppressStartupServiceList"	: true,
			"appName"						: "BedServer"
		]).startup
		
		started.val = true
		return this
	}

	** Shutdown 'afBedSheet'
	BedServer shutdown() {
		checkHasStarted
		registry.shutdown
		reg.val = null
		started.val = false
		modules.val	= Type#.emptyList
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


internal const class BedSheetMetaDataImpl : BedSheetMetaData {
	override const Pod? 		appPod
	override const Type?		appModule
	override const [Str:Obj] 	options
	
	internal new make(Pod? appPod, Type? appModule, [Str:Obj] options) {
		this.appPod 	= appPod
		this.appModule 	= appModule
		this.options 	= options.toImmutable
	}
}
