###*
  @fileoverview TodoMVC view.
###
goog.provide 'este.demos.app.todomvc.todos.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.todomvc.todos.Collection'
goog.require 'este.demos.app.todomvc.todos.templates'
goog.require 'goog.i18n.pluralRules'

class este.demos.app.todomvc.todos.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @enum {string}
  ###
  @Filter:
    ACTIVE: 'active'
    ALL: 'all'
    COMPLETED: 'completed'

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
    @type {este.demos.app.todomvc.todos.View.Filter}
    @protected
  ###
  filter: View.Filter.ALL

  ###*
    Each view is async loaded by default. Load method has to return object
    implementing goog.result.Result interface. It's better than plain old
    callbacks. todo: link to article
    todo: consider move load into presented toward better testability
    @inheritDoc
  ###
  load: (params) ->
    @filter = switch params['filter']
      when 'active'
        View.Filter.ACTIVE
      when 'completed'
        View.Filter.COMPLETED
      else
        View.Filter.ALL

    if !@todos
      @todos = new este.demos.app.todomvc.todos.Collection
      return @localStorage.query @todos
    # parent implementation returns success rusult immediately
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
    length = @todos.getLength()
    remainingCount = @todos.filter('completed': false).length
    json =
      doneCount: length - remainingCount
      filter: @filter
      itemsLocalized: @getLocalizedItems remainingCount
      remainingCount: remainingCount
      todos: @todos.filter @getFilter()
      length: length
    html = este.demos.app.todomvc.todos.templates.element json

    # See how we can merge HTML into element. Better than plain .innerHTML = ,
    # because it updates only changed nodes and attributes, therefore does not
    # destroy form fields states nor cause image flickering.
    @mergeHtml html

  ###*
    @protected
    @return {Object}
  ###
  getFilter: ->
    switch @filter
      when View.Filter.ACTIVE
        {completed: false}
      when View.Filter.COMPLETED
        {completed: true}
      else
        {}

  ###*
    @param {number} remainingCount
    @return {string}
    @protected
  ###
  getLocalizedItems: (remainingCount) ->
    switch goog.i18n.pluralRules.select remainingCount
      when goog.i18n.pluralRules.Keyword.ONE
        @MSG_ONE_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.ZERO
        @MSG_ZERO_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.TWO
        @MSG_TWO_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.FEW
        @MSG_FEW_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.MANY
        @MSG_MANY_ITEMLEFT
      else
        @MSG_OTHER_ITEMLEFT

  ###*
    @desc Items left count in todos view footer.
    @protected
  ###
  MSG_ONE_ITEMLEFT: goog.getMsg 'item left'

  ###*
    @desc Items left count in todos view footer.
    @protected
  ###
  MSG_ZERO_ITEMLEFT: goog.getMsg 'item lefts'

  ###*
    @desc Items left count in todos view footer.
    @protected
  ###
  MSG_TWO_ITEMLEFT: goog.getMsg 'item lefts'

  ###*
    @desc Items left count in todos view footer.
    @protected
  ###
  MSG_FEW_ITEMLEFT: goog.getMsg 'item lefts'

  ###*
    @desc Items left count in todos view footer.
    @protected
  ###
  MSG_MANY_ITEMLEFT: goog.getMsg 'item lefts'

  ###*
    @desc Items left count in todos view footer.
    @protected
  ###
  MSG_OTHER_ITEMLEFT: goog.getMsg 'item lefts'