###*
  @fileoverview este.demos.labs.mvc2.start.
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
  views = [
    este.demos.labs.mvc2.listing.View
    este.demos.labs.mvc2.detail.View
  ]
  myApp = este.mvc.app.create appEl, views

  timer = null
  goog.events.listen myApp, 'beforeviewshow', (e) ->
    progressEl.innerHTML = '<b>loading</b>'
    if e.request.params?.id
      progressEl.innerHTML += ' ' + e.request.params.id
    clearInterval timer
    timer = setInterval ->
      progressEl.innerHTML += '.'
    , 250
  goog.events.listen myApp, 'afterviewshow', ->
    clearInterval timer
    progressEl.innerHTML = 'loaded'

  myApp.data = data
  myApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.labs.mvc2.start', este.demos.labs.mvc2.start