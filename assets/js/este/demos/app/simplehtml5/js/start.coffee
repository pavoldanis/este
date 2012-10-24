###*
  @fileoverview este.demos.app.simplehtml5.start.
###

goog.provide 'este.demos.app.simplehtml5.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.simplehtml5.product.View'
goog.require 'este.demos.app.simplehtml5.products.View'
goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
este.demos.app.simplehtml5.start = (data) ->
  if goog.DEBUG
    este.dev.Monitor.create()

  appEl = document.getElementById 'app'
  progressEl = document.getElementById 'progress'
  timer = null

  # app definition
  myApp = este.app.create appEl, [
    este.demos.app.simplehtml5.products.View
    este.demos.app.simplehtml5.product.View
  ]
  myApp.data = data

  # progress bar, just for demo purposes
  goog.events.listen myApp, 'beforeload', (e) ->
    goog.dom.classes.add progressEl, 'loading'
    progressEl.innerHTML = 'loading'
    progressEl.innerHTML += ' ' + e.request.params.id if e.request.params?.id
    clearInterval timer
    timer = setInterval ->
      progressEl.innerHTML += '.'
    , 250

  goog.events.listen myApp, 'beforeshow', (e) ->
    clearInterval timer
    goog.dom.classes.remove progressEl, 'loading'
    progressEl.innerHTML = 'loaded'

  # dispose
  goog.events.listen document.body, 'click', (e) ->
    return if e.target.id != 'dispose'
    myApp.dispose()

  # start app
  myApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.simplehtml5.start', este.demos.app.simplehtml5.start