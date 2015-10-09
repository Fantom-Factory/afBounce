using concurrent::AtomicBool
using concurrent::AtomicRef
using afConcurrent::LocalRef
using afIoc::Registry
using afIoc::RegistryBuilder
using wisp::MemWispSessionStore
using wisp::WispSessionStore
using afBedSheet::BedSheetBuilder
using afBedSheet::BedSheetModule
using afButter::Butter
using afButter::HttpTerminator

** Initialises a Bed App without the overhead of starting the 'wisp' web server. 
** 
** 'BedServer' is a 'const' class so it may be used in multiple threads. Do this to create 'BedClients' in different
** threads to make concurrent calls - handy for load testing.
const class BedServer {
	private const static Log	log 		:= BedServer#.pod.log

	private const AtomicRef		reg			:= AtomicRef()
	private const AtomicBool	started		:= AtomicBool()
	private const LocalRef	 	builderRef	:= LocalRef("bedSheetBuilder")

	** The underlying 'BedSheetBuilder' instance.
	BedSheetBuilder bedSheetBuilder {
		get { builderRef.val }
		private
		set { builderRef.val = it }
	}

	** The IoC registry.
	Registry registry {
		get { checkHasStarted; return reg.val }
		private set { reg.val = it }
	}

	** Returns the options from the IoC 'RegistryBuilder'.
	** Read only.
	Str:Obj? options {
		get { bedSheetBuilder.options }
		private set { throw Err("Read only") }
	}

	** Create a 'BedServer' instance with the given qname of either a Pod or a Type. 
	new makeWithName(Str qname) {
		this.builderRef.val = BedSheetBuilder(qname)
	}

	** Create a 'BedServer' instance with the given IoC module (usually your web app).
	new makeWithModule(Type iocModule) {
		this.builderRef.val = BedSheetBuilder(iocModule.qname)
	}

	** Create a 'BedServer' instance with the given pod (usually your web app).
	new makeWithPod(Pod webApp) {
		this.builderRef.val = BedSheetBuilder(webApp.name)
	}

	** Adds an extra (test) module to the registry, should you wish to override service behaviour.
	** 
	** Convenience for 'bedSheetBuilder.addModule()'
	BedServer addModule(Type iocModule) {
		checkHasNotStarted
		bedSheetBuilder.addModule(iocModule)
		return this
	}

	** Adds many modules to the registry
	** 
	** Convenience for 'bedSheetBuilder.addModules()'
	This addModules(Type[] moduleTypes) {
		checkHasNotStarted
		bedSheetBuilder.addModules(moduleTypes)
		return this
	}
	
	** Inspects the [pod's meta-data]`docLang::Pods#meta` for the key 'afIoc.module'. This is then 
	** treated as a CSV list of (qualified) module type names to load.
	** 
	** If 'addDependencies' is 'true' then the pod's dependencies are also inspected for IoC 
	** modules.
	**  
	** Convenience for 'bedSheetBuilder.addModulesFromPod()'
	This addModulesFromPod(Str podName, Bool addDependencies := true) {
		checkHasNotStarted
		bedSheetBuilder.addModulesFromPod(podName, addDependencies)
		return this		
	}
	
	** Startup 'afBedSheet'
	BedServer startup() {
		checkHasNotStarted
		
		bedSheetBuilder.options["afIoc.bannerText"]		= "Alien-Factory BedServer v${typeof.pod.version}, IoC v${Registry#.pod.version}" 
		bedSheetBuilder.options["afBedSheet.appName"]	= "BedServer"
			
		registry = bedSheetBuilder.build
		started.val = true
		return this
	}

	** Shutdown 'afBedSheet'
	BedServer shutdown() {
		if (started.val)
			registry.shutdown
		reg.val = null
		started.val = false
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
	Obj serviceById(Str serviceId, Bool checked := true) {
		checkHasStarted; checkHasNotShutdown
		return registry.activeScope.serviceById(serviceId, checked)
	}

	** Helper method - tap into BedSheet's afIoc registry
	Obj dependencyByType(Type dependencyType, Bool checked := true) {
		checkHasStarted; checkHasNotShutdown
		return registry.activeScope.serviceByType(dependencyType, checked)
	}

	** Helper method - tap into BedSheet's afIoc registry
	Obj autobuild(Type type, Obj?[]? ctorArgs := null, [Field:Obj?]? fieldVals := null) {
		checkHasStarted; checkHasNotShutdown
		return registry.activeScope.build(type, ctorArgs, fieldVals)
	}

	** Helper method - tap into BedSheet's afIoc registry
	Obj injectIntoFields(Obj service) {
		checkHasStarted; checkHasNotShutdown
		return registry.activeScope.inject(service)
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
