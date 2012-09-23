###*
  @fileoverview Stay tuned for TodoMVC demo.
###

goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'
goog.require 'goog.dom'
goog.require 'goog.events'

###*
  @param {Object} data JSON from server
###
app.start = (data) ->

  if goog.DEBUG
    este.dev.Monitor.create()

  box = goog.dom.createDom 'div',
    style: 'width: 100px; height: 100px; background-color: #ff8c55'
    innerHTML: 'Click on me'

  document.body.appendChild box

  goog.events.listen box, 'click', ->
    alert 'It works.'

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start

