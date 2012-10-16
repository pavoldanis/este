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
    Each view is async loaded by default. Load method has to return object
    implementing goog.result.Result interface. It's better than plain old
    callbacks. todo: link to article
    @inheritDoc
  ###
  load: (params) ->
    @localStorage.query @todos

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @update()
    @on @todos, 'change', @onTodosChange
    @delegate '#new-todo-form', 'submit', @onNewTodoSubmit
    @delegate '.toggle', 'tap', @onToggleTap
    @delegate '#toggle-all', 'tap', @onToggleAllTap
    @delegate '.destroy', 'tap', @onDestroyTap
    @delegate '#clear-completed', 'tap', @onClearCompletedTap
    @delegate 'label', 'dblclick', @onLabelDblclick
    @delegate '.edit', 'blur', @onEditEnd
    @delegate '.edit', goog.events.KeyCodes.ENTER, @onEditEnd

  ###*
    @protected
  ###
  onTodosChange: (e) ->
    # todo: investigate direct update
    @defer @update
    # @defer @persist

  ###*
    @protected
  ###
  onNewTodoSubmit: (e) ->
    e.preventDefault()

    todo = new este.demos.app.todomvc.todo.Model e.json
    errors = todo.validate()
    return if errors

    e.target.elements['title'].value = ''
    @todos.add todo

  ###*
    @protected
  ###
  onToggleTap: (e) ->
    e.model.toggleCompleted()

  ###*
    @protected
  ###
  onToggleAllTap: (e) ->
    allCompleted = !@todos.filter('completed': false).length
    @todos.toggleCompleted !allCompleted

  ###*
    @protected
  ###
  onDestroyTap: (e) ->
    @todos.remove e.model

  ###*
    @protected
  ###
  onClearCompletedTap: (e) ->
    @todos.clearCompleted()

  ###*
    @protected
  ###
  onLabelDblclick: (e) ->
    e.model.set 'editing', true
    edit = e.modelElement.querySelector '.edit'
    este.dom.focus edit

  ###*
    @protected
  ###
  onEditEnd: (e) ->
    title = goog.string.trim e.modelElement.querySelector('.edit').value
    if !title
      @todos.remove e.model
      return
    e.model.set
      'title': title
      'editing': false
    return

  ###*
    @protected
  ###
  update: ->
    remainingCount = @todos.filter('completed': false).length
    doneCount = @todos.getLength() - remainingCount
    itemLeft = if remainingCount == 1 then 'item left' else 'items left'

    json =
      todos: @todos.toJson()
      remainingCount: remainingCount
      doneCount: doneCount
      itemLeft: itemLeft
    html = este.demos.app.todomvc.todos.templates.element json

    # See how me can merge new HTML into existing element. Better than plain
    # old .innerHTML = html, because innerHTML destroys DOM state.
    este.dom.merge @getElement(), html

    return

  ###*
    @inheritDoc
  ###
  persist: ->