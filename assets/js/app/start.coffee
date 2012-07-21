###*
  @fileoverview Stay tuned for TodoMVC demo.
###

goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
app.start = (data) ->
  
# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start

