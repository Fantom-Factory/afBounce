# Bounce

`Bounce` is a [Fantom](http://fantom.org/) library for testing [Bed Applications](http://www.fantomfactory.org/pods/afBedSheet).

`Bounce` is a testing framework that makes requests to a [Bed App](http://www.fantomfactory.org/pods/afBedSheet) without the
overhead of starting up a web server and making expensive network requests.


## Install

Install `Bounce` with the Fantom Respository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    $ fanr install -r http://repo.status302.com/fanr/ afBounce

Or to install manually, download the pod from [Status302](http://repo.status302.com/browse/afBounce) and copy it to `%FAN_HOME%/lib/fan/`.

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afBounce 0+"]



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afBounce/#overview).



## Quick Start

1). Create a text file called `Example.fan`:

    using afBounce
    using afBedSheet::Text
    using afBedSheet::Route
    using afBedSheet::Routes
    using afIoc
    
    class Example : Test {
        Void testBedApp() {
            // given
            server := BedServer(Type.find("Example_0::AppModule")).startup
            client := server.makeClient
    
            // when
            client.get(`/index`)
    
            // then
            title := client.select("#title").first
            verifyEq(title.text.writeToStr, "Sizzle Kicks Ass!")
        }
    }
    
    ** A Really Simple Bed App!!!
    class AppModule {
        @Contribute { serviceType=Routes# }
        static Void contributeRoutes(OrderedConfig config) {
            config.add(Route(`/index`, Text.fromHtml("""<html><p id="title">Sizzle Kicks Ass!</p></html>""")))
        }
    }

2). Run `Example.fan` as a Fantom test script ( [fant](http://fantom.org/doc/docTools/Fant.html) ) from the command line:

    C:\> fant Example.fan
    
    -- Run:  Example_0::Example.testBedApp...
    [info] [afIoc] Adding modules from dependencies of 'afBedSheet'
    [info] [afIoc] Adding module definition for afBedSheet::BedSheetModule
    [info] [afIoc] Adding module definition for afIocConfig::IocConfigModule
    [info] [afIoc] Adding module definition for afIocEnv::IocEnvModule
    [info] [afIoc] Adding module definition for Example_0::AppModule
    [info] [afIoc]
       ___    __                 _____        _
      / _ |  / /  _____  _____  / ___/__  ___/ /_________  __ __
     / _  | / /_ / / -_|/ _  / / __// _ \/ _/ __/ _  / __|/ // /
    /_/ |_|/___//_/\__|/_//_/ /_/   \_,_/__/\__/____/_/   \_, /
              Alien-Factory BedServer v0.0.2, IoC v1.5.0 /___/
    
    BedServer started up in 597ms
    
       Pass: Example_0::Example.testBedApp [1]
    
    Time: 2052ms
    
    ***
    *** All tests passed! [1 tests, 1 methods, 1 verifies]
    ***

