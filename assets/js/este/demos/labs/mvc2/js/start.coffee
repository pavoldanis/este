###*
  @fileoverview Experimental MVC stuff.
###

goog.provide 'este.demos.labs.mvc2.start'

goog.require 'este.demos.labs.mvc2.detail.View'
goog.require 'este.demos.labs.mvc2.listing.View'
goog.require 'este.dev.Monitor.create'
goog.require 'este.mvc.app.create'

###*
  @param {Object} data JSON from server
###
este.demos.labs.mvc2.start = (data) ->
  if goog.DEBUG
    este.dev.Monitor.create()

  progressEl = document.getElementById 'progress'

  appEl = document.getElementById 'app'
  myApp = este.mvc.app.create appEl, [
    este.demos.labs.mvc2.listing.View
    este.demos.labs.mvc2.detail.View
  ]

  goog.events.listen myApp, 'fetch', ->
    progressEl.innerHTML = 'loading'
  goog.events.listen myApp, 'fetched', ->
    progressEl.innerHTML = 'loaded'

  myApp.data = data
  myApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.labs.mvc2.start', este.demos.labs.mvc2.start