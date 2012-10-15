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
    # todo: add support for touch devices via tap event
    @delegate 'label', 'dblclick', @onLabelDblclick
    @delegate '.edit', 'blur', @onEditEnd
    @delegate '.edit', goog.events.KeyCodes.ENTER, @onEditEnd
    @delegate '.destroy', 'tap', @onDestroyTap

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
  onLabelDblclick: (e) ->
    e.model.set 'editing', true
    edit = e.modelElement.querySelector '.edit'
    este.dom.focus edit

  ###*
    @protected
  ###
  onEditEnd: (e) ->
    title = goog.string.trim e.modelElement.querySelector('.edit').value
    # if !title
    #   @todos.remove e.model
    #   return
    e.model.set
      'title': title
      'editing': false
    return

  ###*
    @protected
  ###
  onDestroyTap: (e) ->
    @todos.remove e.model

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

    # console.log JSON.stringify @todos.toJson()
    # todo:
    #   consider: separate updateHtml method
    #   explain non destructive innerHTML and why&when it should be used
    #   explain when to render whole template and when render inner templates separately
    html = este.demos.app.todomvc.todos.templates.element json
    # console.log html
    este.dom.merge @getElement(), html
    # @getElement().innerHTML = html
    # console.log 'todos view updated'
    return

  ###*
    @inheritDoc
  ###
  persist: ->