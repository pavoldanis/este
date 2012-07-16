##07/15/12

  - ported `visionmedia/page.js`, see [page.js](http://visionmedia.github.com/page.js/)

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
