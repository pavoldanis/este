###*
  @fileoverview este.demos.app.todomvc.todos.View.
###
goog.provide 'este.demos.app.todomvc.todos.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.todomvc.todos.Collection'
goog.require 'este.demos.app.todomvc.todos.templates'

class este.demos.app.todomvc.todos.View extends este.app.View

  ###*
    @param {este.demos.app.todomvc.todos.Collection=} todos
    @constructor
    @extends {este.app.View}
  ###
  constructor: (todos) ->
    super()
    @todos = todos ? new este.demos.app.todomvc.todos.Collection

  ###*
    @inheritDoc
  ###
  url: ''

  ###*
    @type {este.demos.app.todomvc.todos.Collection}
    @protected
  ###
  todos: null

  ###*
    @inheritDoc
  ###
  load: (params) ->
    @localStorage.query @todos

  ###*
    @inheritDoc
  ###
  render: ->
    @getElement().innerHTML = este.demos.app.todomvc.todos.templates.items()
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @on @todos, 'change', @onTodosChange

    # tap handler
    # submit (cross?)

    @delegate '#clear-completed', 'click', @onClearCompletedClick
    @delegate '#new-todo', goog.events.KeyCodes.ENTER, @onNewTodoEnter

    # @delegate '#clear-completed', 'tap': @onClearCompletedTap
    # @delegate '#new-fok', 'submit', @onNewFokSubmit

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onClearCompletedClick: (e) ->
    window['console']['log'] e.type

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onNewTodoEnter: (e) ->
    window['console']['log'] 'enter'

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onTodosChange: (e) ->
    # todo: persist and render