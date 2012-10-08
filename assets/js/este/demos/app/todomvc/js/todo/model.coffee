###*
  @fileoverview este.demos.app.todomvc.todo.Model.
###
goog.provide 'este.demos.app.todomvc.todo.Model'

goog.require 'este.Model'

class este.demos.app.todomvc.todo.Model extends este.Model

  ###*
    @param {Object=} json
    @constructor
    @extends {este.Model}
  ###
  constructor: (json) ->
    super json

  ###*
    @inheritDoc
  ###
  defaults:
    'title': ''
    'completed': false
    'editing': false

  ###*
    @inheritDoc
  ###
  schema:
    'title':
      'set': este.model.setters.trim
      'validators':
        'required': este.model.validators.required

  toggleCompleted: ->
    completed = @get 'completed'
    @set 'completed', !completed
