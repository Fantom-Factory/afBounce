using afIoc
using afBedSheet

class T_AppModule {

	static Void bind(ServiceBinder binder) {
		
	}
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(OrderedConfig config) {
		config.add(Route(`/index`, T_Pages#index))
	}
	
}
