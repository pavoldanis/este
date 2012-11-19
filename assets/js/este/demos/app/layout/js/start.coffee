###*
  @fileoverview este.demos.app.layout.start.
###

goog.provide 'este.demos.app.layout.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.layout.bla.View'
goog.require 'este.demos.app.layout.foo.View'
goog.require 'este.demos.app.layout.index.View'
goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
este.demos.app.layout.start = (data) ->

  if goog.DEBUG
    este.dev.Monitor.create()

  appEl = document.getElementById 'app'

  myApp = este.app.create appEl, [
    este.demos.app.layout.bla.View
    este.demos.app.layout.foo.View
    este.demos.app.layout.index.View
  ], true
  myApp.data = data
  myApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.layout.start', este.demos.app.layout.start