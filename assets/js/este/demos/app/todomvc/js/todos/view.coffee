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

  ###*
    undefined, active, completed
    @inheritDoc
  ###
  url: '/:filter?'

  ###*
    @type {este.demos.app.todomvc.todos.Collection}
    @protected
  ###
  todos: null

  ###*
    todo: consider enum
    @type {string}
    @protected
  ###
  filter: ''

  ###*
    Each view is async loaded by default. Load method has to return object
    implementing goog.result.Result interface. It's better than plain old
    callbacks. todo: link to article
    @inheritDoc
  ###
  load: (params) ->
    @filter = params['filter']
    if !@todos
      @todos = new este.demos.app.todomvc.todos.Collection
      return @localStorage.query @todos
    super()

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @update()
    @on @todos, 'update', @onTodosUpdate
    @on '#new-todo-form', 'submit', @onNewTodoSubmit
    @on '.toggle', 'tap', @onToggleTap
    @on '#toggle-all', 'tap', @onToggleAllTap
    @on '.destroy', 'tap', @onDestroyTap
    @on '#clear-completed', 'tap', @onClearCompletedTap
    @on 'label', 'dblclick', @onLabelDblclick
    @on '.edit', 'blur', @onEditEnd
    @on '.edit', goog.events.KeyCodes.ENTER, @onEditEnd

  ###*
    @param {este.Model.Event} e
    @protected
  ###
  onTodosUpdate: (e) ->
    @defer @update
    @localStorage.saveChanges e

  ###*
    @protected
  ###
  onNewTodoSubmit: (e) ->
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
    # onEditEnd is registered both for blur and key enter, if key enter removes
    # some todo, then blur e.modelElement is undefined.
    return if !e.modelElement
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
    # todo: refactor
    remainingCount = @todos.filter('completed': false).length
    todosLength = @todos.getLength()
    filterObject = {}
    if @filter
      isCompleted = @filter == 'completed'
      filterObject['completed'] = isCompleted
      filter = if isCompleted then 'completed' else 'active'
    else
      filter = 'all'
    todos = @todos.filter filterObject
    json =
      doneCount: todosLength - remainingCount
      filter: filter
      itemsLocalized: @getLocalizedItems remainingCount
      remainingCount: remainingCount
      todos: todos
      todosLength: todosLength
    html = este.demos.app.todomvc.todos.templates.element json

    # See how we can merge HTML into element. Better than plain .innerHTML = ,
    # because it updates only changed nodes and attributes, therefore does not
    # destroy form fields states nor cause image flickering.
    @mergeHtml html

  ###*
    @param {number} remainingCount
    @return {string}
    @protected
  ###
  getLocalizedItems: (remainingCount) ->
    # see goog.i18n.pluralRules for other languages plural rules
    switch goog.i18n.pluralRules.select remainingCount
      when goog.i18n.pluralRules.Keyword.ONE
        'item left'
      else
        'items left'