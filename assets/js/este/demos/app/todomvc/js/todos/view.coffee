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
  update: ->
    # console.log 'fok'
    remainingCount = @todos.filter('completed': false).length
    doneCount = @todos.getLength() - remainingCount
    itemLeft = if remainingCount == 1 then 'item left' else 'items left'

    json =
      todos: @todos.toJson()
      remainingCount: remainingCount
      doneCount: doneCount
      itemLeft: itemLeft

    # todo:
    #   consider: separate updateHtml method?
    #   explain non destructive innerHTML and why&when it should be used
    html = este.demos.app.todomvc.todos.templates.element json
    # todo: explain when render all template and when render inner templates
    # separately
    este.dom.merge @getElement(), html
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @on @todos, 'change', @onTodosChange
    @delegate '#new-todo-form', 'submit', @onNewTodoSubmit
    @delegate '.toggle', 'tap', @onToggleTap
    @delegate '#toggle-all', 'tap', @onToggleAllTap
    # todo: add support for touch devices via alternate tap event
    @delegate 'label', 'dblclick', @onLabelDblclick
    @delegate '.edit', 'blur', @onEditBlur
    @delegate '.edit', goog.events.KeyCodes.ENTER, @onEditBlur

    # @delegate '#clear-completed', 'click', @onClearCompletedClick
    # @delegate 'input.field', ['focus', 'blur'], @onClearCompletedClick
    # # for mobile and desktop both
    # @delegate '#clear-completed', 'tap': @onClearCompletedTap

  ###*
    @protected
  ###
  onTodosChange: (e) ->
    @defer @update
    # todo: persist and onLoad

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
  onEditBlur: (e) ->
    title = e.modelElement.querySelector '.edit'
    e.model.set
      'title': title.value
      'editing': false


  # ###*
  #   @param {goog.events.BrowserEvent} e
  #   @protected
  # ###
  # onClearCompletedClick: (e) ->
  #   window['console']['log'] e.type
