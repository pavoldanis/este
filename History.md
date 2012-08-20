##08/16/12
  - run.coffee one letter options

##08/16/12
  - demos/labs/mvc2 demo released

##08/14/12
  - Closure class syntax updated to CoffeeScript
  - bug in coffee4class fixed, empty constructors works now
  - Chai.js updated to 1.2.0

##08/09/12
  - este mvc first demo released
  - git ignores fixed, no need to specify another namespaces
  - page.js removed, use este.router.Router
  - Google Closure updated
  - mocked Elemented firstChild and lastChild

##08/02/12
  - Mocha and Closure updated

##08/01/12
  - `este.router.SimpleRouter` released
  - `este.mvc` namespaces removed

##07/31/12

  - `este.dev.CoffeeForClosure` handles also namespaces
  - shorter este.events handlers names, for example
    - `este.events.TapEventHandler` to `este.events.TapHandler`
  - `este.events.TapHandler` demo added
  - links to demos added, e.g. @see ../demos/lightbox.html etc.
  - `este.History` refactored

##07/28/12

  - breaking changes: `este.oop` removed, `este.mvc.*` renamed
    - `este.mvc.Model` -> `este.Model`
    - `este.mvc.Collection` -> `este.Collection`

##07/27/12

  - build fixed
  - `este.mvc.Model` converted into CoffeeScript Class
  - `este.router.SimpleRouter` proposal

##07/22/12

  - CoffeeScript class syntax for Google Closure! (dancing)
  - several run script bugs fixed
  - console.log within unit tests works

##07/17/12

  - `este.History` cleaned, demo added

##07/16/12

  - added `este.Page`, ported [visionmedia/page.js](http://visionmedia.github.com/page.js/)

##07/15/12

  - `este.dom.merge` redesigned, demo added

##07/14/12

  - `node run este --deploy` to compile all este source files (fine for dev)
  - Google Closure and Compiler updated
  - added `este.style`

##07/10/12

  - added `este.dom.merge`
  - added `este.dom.forceBlur`

##07/08/12

  - added `este.ui.FormsPersister` persist forms states into localstorage or session

##07/08/12

  - added `assets/js/este/demos/index.html`
  - CoffeeScript, Mocha and Stylus were unglobalized. No need to install them
  - Live reload improvement, styles are refreshed instantly without page reload

##07/07/12

  - Live reloading is coming to town! In dev mode, browser tab is reloaded
    automatically when needed. No more F5 nor CMD-R.
  - Google Closure no more as git submodule.

##07/06/12

  - run script fixes
  - welcome new este library commiter: jiri.kopsa@proactify.com
  - snippets for Sublime https://github.com/Steida/Sublimetext-user-settings

##07/01/12

  - one `node run app` script for everything
  - default este sublime project file

##06/30/12

  - start script
      - refactored and speeded up, many bugs were fixed
      - documentation
      - onfilechange unit testing is faster
      - debug option, detail time durations for each command
      - `deps.js` is defined for all `assets/js` subdirectories
