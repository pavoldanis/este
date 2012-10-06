###*
  @fileoverview este.demos.app.todomvc.todos.View.
###
goog.provide 'este.demos.app.todomvc.todos.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.todomvc.todos.Collection'
goog.require 'este.demos.app.todomvc.todos.templates'

class este.demos.app.todomvc.todos.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()
    @todos = new este.demos.app.todomvc.todos.Collection

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
    Loading is async by default. How this method works? localStorage.query
    returns object with goog.result.Result interface, instead of old callback.
    @inheritDoc
  ###
  load: (params) ->
    @localStorage.query @todos

  ###*
    @inheritDoc
  ###
  update: ->
    remainingCount = @todos.filter('completed': false).length
    doneCount = @todos.getLength() - remainingCount
    json =
      todos: @todos.toJson()
      remainingCount: remainingCount
      doneCount: doneCount

    # consider: separate updateHtml method?
    # todo: explain non destructive innerHTML and why&when it should be used
    html = este.demos.app.todomvc.todos.templates.items json
    este.dom.merge @getElement(), html
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @on @todos, 'change', @onTodosChange
    # @delegate '#new-todo', goog.events.KeyCodes.ENTER, @onNewTodoEnter
    @delegate '#new-todo-form', 'submit', @onNewTodoSubmit
    @delegate '.toggle', 'click', @onToggleClick

    # @delegate '#clear-completed', 'click', @onClearCompletedClick
    # @delegate 'input.field', ['focus', 'blur'], @onClearCompletedClick
    # # for mobile and desktop both
    # @delegate '#clear-completed', 'tap': @onClearCompletedTap
    # # submit can bubble to, with automatic form2json

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onTodosChange: (e) ->
    @update()
    # todo: persist and onLoad

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onNewTodoSubmit: (e) ->
    e.preventDefault()
    todo = new este.demos.app.todomvc.todo.Model e.json
    errors = todo.validate()
    return if errors
    # see how we don't have to use querySelector to retrieve #new-todo.
    # Fields names are projected into form.elements.
    e.target.elements['title'].value = ''
    @todos.add todo

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onToggleClick: (e) ->
    # Closure Compiler has a really good type interference. At methods returns
    # value annotated as {*}, still compiler checks toggleCompleted method.
    @todos.at(0).toggleCompleted()
    # todo = @getTodoFromEvent e
    # todo.toggleCompleted()

  ###*
    @param {goog.events.BrowserEvent} e
    @return {este.demos.app.todomvc.todo.Model}
    @protected
  ###
  getTodoFromEvent: (e) ->
    # @findModelByClientId @todos, e
    # console.log 'f'

    # clientId = @lookupClientId e.target
    # return null if !clientId
    # todo = @todos.lookupClientId clientId
    # return null if !todo
    # todo

  # toggleStatus: ->
  #   @todo.updateAttribute 'completed', !@todo.completed

  # ###*
  #   @param {goog.events.BrowserEvent} e
  #   @protected
  # ###
  # onNewTodoEnter: (e) ->
  #   # via model, value is trimmed and validated
  #   todo = new este.demos.app.todomvc.todo.Model
  #     'title': e.target.value
  #   # validate method returns validations error or null
  #   return if todo.validate()
  #   # reset input value and add new todo into collection
  #   e.target.value = ''
  #   @todos.add todo

  # ###*
  #   @param {goog.events.BrowserEvent} e
  #   @protected
  # ###
  # onClearCompletedClick: (e) ->
  #   window['console']['log'] e.type
