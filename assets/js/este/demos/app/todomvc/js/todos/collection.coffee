###*
  @fileoverview este.demos.app.todomvc.todos.Collection.
###
goog.provide 'este.demos.app.todomvc.todos.Collection'

goog.require 'este.Collection'
goog.require 'este.demos.app.todomvc.todo.Model'

class este.demos.app.todomvc.todos.Collection extends este.Collection

  ###*
    @param {Array=} array
    @constructor
    @extends {este.Collection}
  ###
  constructor: (array) ->
    super array

  ###*
    @inheritDoc
  ###
  model: este.demos.app.todomvc.todo.Model

  ###*
    @param {boolean} completed
  ###
  toggleCompleted: (completed) ->
    @each (item) -> item.set 'completed', completed

  clearCompleted: ->
    @removeIf (todo) -> todo.get 'completed'