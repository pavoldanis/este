###*
  @fileoverview Stay tuned for TodoMVC demo.
###

goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
app.start = (data) ->

  if goog.DEBUG
    este.dev.Monitor.create()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start

