###*
  @fileoverview este.demos.app.todomvc.start.
###

goog.provide 'este.demos.app.todomvc.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.todomvc.todos.View'
goog.require 'este.dev.Monitor.create'
goog.require 'este.storage.Local'

###*
  @param {Object} data JSON from server
###
este.demos.app.todomvc.start = (data) ->
  if goog.DEBUG
    este.dev.Monitor.create()

  app = este.app.create 'todoapp', [
    este.demos.app.todomvc.todos.View
  ], true
  app.storage = new este.storage.Local 'todos-este'
  app.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.todomvc.start', este.demos.app.todomvc.start