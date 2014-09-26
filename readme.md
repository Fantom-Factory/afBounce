## Overview 

`Bounce` - use it to test your [BedSheet Apps](http://www.fantomfactory.org/pods/afBedSheet)!

`Bounce` is a testing framework that makes requests to your [Bed App](http://www.fantomfactory.org/pods/afBedSheet) without the expensive overhead of starting a web server, opening ports, and making network connections.

`Bounce` uses rich [CSS selectors](http://www.fantomfactory.org/pods/afSizzle) and a simple API to let you query and verify your web pages.

## Install 

Install `Bounce` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afBounce

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afBounce 1.0+"]

## Documentation 

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afBounce/).

## Quick Start 

1). Create a text file called `Example.fan`:

```
using afBounce
using afBedSheet
using afIoc

class Example : Test {
    Void testBedApp() {
        // given
        server := BedServer(AppModule#).startup
        client := server.makeClient

        // when
        client.get(`/index`)

        // then
        title := Element("#title")
        title.verifyTextEq("Bed Bouncing!")

        // clean up
        server.shutdown
    }
}

** A Really Simple Bed App!!!
class AppModule {
    @Contribute { serviceType=Routes# }
    static Void contributeRoutes(OrderedConfig config) {
        config.add(Route(`/index`, Text.fromHtml("""<html><p id="title">Bed Bouncing!</p></html>""")))
    }
}
```

2). Run `Example.fan` as a Fantom test script ( [fant](http://fantom.org/doc/docTools/Fant.html) ) from the command line:

```
C:\> fant Example.fan

-- Run:  Example_0::Example.testBedApp...
[info] [afIoc] Adding modules from dependencies of 'afBedSheet'
[info] [afIoc] Adding module definition for afBedSheet::BedSheetModule
[info] [afIoc] Adding module definition for afIocConfig::IocConfigModule
[info] [afIoc] Adding module definition for afIocEnv::IocEnvModule
[info] [afIoc] Adding module definition for Example_0::AppModule
[info] [afIoc]
   ___    __                 _____        _
  / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
 / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
/_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
         Alien-Factory BedServer v1.0.16, IoC v2.0.0 /___/

BedServer started up in 597ms

   Pass: Example_0::Example.testBedApp [1]

Time: 2052ms

***
*** All tests passed! [1 tests, 1 methods, 1 verifies]
***
```

## Usage 

Use [BedServer](http://repo.status302.com/doc/afBounce/BedServer.html) to start an instance of your [Bed App](http://www.fantomfactory.org/pods/afBedSheet), and then use [BedClient](http://repo.status302.com/doc/afBounce/BedClient.html) make repeated requests against it. The HTML elements are then used to verify that correct content is rendered.

`BedClient` is a `ButterDish` that wraps a `Butter` instance - all functionality is provided by [Butter](http://www.fantomfactory.org/pods/afButter) middleware. [BedTerminator](http://repo.status302.com/doc/afBounce/BedTerminator.html) is the terminator of the stack, which sends requests to [BedServer](http://repo.status302.com/doc/afBounce/BedServer.html), which holds the instance of your [Bed App](http://www.fantomfactory.org/pods/afBedSheet).

### Verify HTML Content 

When queried, the HTML classes ( [Element](http://repo.status302.com/doc/afBounce/Element.html), [TextBox](http://repo.status302.com/doc/afBounce/TextBox.html), etc...) use the last response from the client. The client stores itself in the `Actor.locals()` map, and the HTML elements implicitly use this value. This means you can define your Elements once (in a mixin if need be) and use them over and over without needing to track the response they're querying. Example:

```
    // deinfe your elements
    title := Element("h1")
    link  := Element("#page2")

    // use them
    client.get(`/index`)
    title.verifyTextEq("Home Page")

    link.click
    title.verifyTextEq("Page2")
```

### Inspect the WebSession 

It is often useful to inspect, assert against, or even set values in, a client's web session. As the `BedClient` holds the session, this is easy!

```
using afBounce

class TestMyBedApp : Test {
    Void testBedApp() {
        server := BedServer(AppModule#).startup
        client := server.makeClient

        ....

        // set values in the user's session
        client.webSession["userName"] = "Emma"

        // assert against session values
        verifyNotNull(client.webSession["shoppingCart"])
    }
}
```

### Inject Services Into Tests 

`BedServer` has access to the [IoC](http://www.fantomfactory.org/pods/afIoc) registry used by your Bed App, this lets you inject services into your test.

```
using afBounce
using afIoc

class TestMyBedApp : Test {

    @Inject
    MyService myService

    Void testBedApp() {
        server := BedServer(AppModule#).startup

        // inject services into test
        server.injectIntoFields(this)

        ...
    }
}
```

### Override Services 

`BedServer` lets you specify additional Ioc modules, letting you add custom test modules that override or stub out real services with test ones.

```
using afBounce

class TestMyBedApp : Test {

    Void testBedApp() {
        server := BedServer(AppModule#)

        // override services with test implementations
        server.addModule(TestOverrides#)

        server.startup

        ....
    }
}
```

## Test Outside The Box! 

By creating `BedClient` with a `Butter` stack that ends with a real HTTP terminator, `Bounce` can also be used to test web applications in any environment. Example:

```
using afBounce
using afButter

class TestFantomFactory : Test {

    Void testFantomFactory() {
        // add Sizzle to the default middleware stack
        client := BedClient(Butter.churnOut(
            Butter.defaultStack.insert(0, SizzleMiddleware())
        ))

        // make real http requests to your integration environment
        client.get(`http://www.fantomfactory.org/pods/afBounce`)

        // use sizzle to test
        tagLine := Element(".jumbotronic h1 + p")
        tagLine.verifyTextEq("A library for testing Bed applications!")
    }
}
```

## Not Just for Bed Apps! 

The HTML element classes ( [Element](http://repo.status302.com/doc/afBounce/Element.html), [TextBox](http://repo.status302.com/doc/afBounce/TextBox.html), etc...) are not just for testing Bed Applications! By setting a [SizzleDoc](http://repo.status302.com/doc/afSizzle/SizzleDoc.html) instance in `Actor.locals()` with the key `afBounce.sizzleDoc` you can use the HTML classes with any HTML:

```
using afBounce
using afSizzle

class TestHtml : Test {

    Void testHtml() {
        xhtml := "<html xmlns="http://www.w3..."  // --> your XHTML
        Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(xhtml)

        success := Element("span.success")
        success.verifyTextEq("Awesome!")

        Actor.locals.remove("afBounce.sizzleDoc")
    }
}
```

