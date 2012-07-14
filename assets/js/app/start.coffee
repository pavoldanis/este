###*
  @fileoverview Stay tuned for TodoMVC demo.
###

goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'

app.start = ->

  if goog.DEBUG
    este.dev.Monitor.create()

# ensures the symbol will be visible after compiler renaming.
goog.exportSymbol 'app.start', app.start