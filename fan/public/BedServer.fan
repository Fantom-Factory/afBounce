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
using afButter::ErrOn500Middleware

** For testing 'BedSheet' apps: Run tests against 'BedSheet' without starting a 'wisp' web server.
** Testing your web app is as simple as:
** 
**   Void testMywebApp() {
**     server   := BedServer(AppModule#).startup
**     client   := server.makeClient
**     response := client.get(`/hello`)
** 
**     verifyEq(response.statusCode, 200)
**     verifyEq(response.asStr, "Hello!")
**         
**     server.shutdown
**   }
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
		
		mod := BedSheetWebMod.findModFromPod(webApp)
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
	
	// FIXME: bedClient? - add middleware
	** Create a `BedClient` that makes requests against this server
	Butter makeClient() {
		checkHasStarted
		// add BounceDish for shutdown()
		return BounceButterDish(Butter.churnOut([
			SizzleMiddleware(),
			ErrOn500Middleware(),
			BedTerminator(this)
		]))
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
