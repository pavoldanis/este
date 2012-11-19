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
  url: -> '/:filter?'

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
    @inheritDoc
  ###
  events: ->
    super()
    @on
      '#new-todo-form submit': @onNewTodoSubmit
      '.toggle tap': @onToggleTap
      '#toggle-all tap': @onToggleAllTap
      '.destroy tap': @onDestroyTap
      '#clear-completed tap': @onClearCompletedTap
      'label dblclick': @onLabelDblclick
      '.edit blur': @onEditEnd
      '.edit': [goog.events.KeyCodes.ENTER, @onEditEnd]

  ###*
    @param {Array.<este.Model.Event>} events
    @protected
  ###
  onModelUpdate: (events) ->
    for event in events
      @localStorage.saveChanges event
    @update()

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
    @param {este.demos.app.todomvc.todo.Model} model
    @protected
  ###
  onToggleTap: (model) ->
    model.toggleCompleted()

  ###*
    @protected
  ###
  onToggleAllTap: ->
    completed = @todos.completed()
    @todos.toggleCompleted !completed

  ###*
    @param {este.demos.app.todomvc.todo.Model} model
    @protected
  ###
  onDestroyTap: (model) ->
    @todos.remove model

  ###*
    @protected
  ###
  onClearCompletedTap: ->
    @todos.clearCompleted()

  ###*
    @param {este.demos.app.todomvc.todo.Model} model
    @param {Element} el
    @protected
  ###
  onLabelDblclick: (model, el) ->
    model.set 'editing', true
    edit = el.querySelector '.edit'
    este.dom.focus edit

  ###*
    @param {este.demos.app.todomvc.todo.Model} model
    @param {Element} el
    @protected
  ###
  onEditEnd: (model, el) ->
    edit = el.querySelector '.edit'
    title = goog.string.trim edit.value
    if !title
      @todos.remove model
      return

    model.set
      'title': title
      'editing': false

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
      # setModel enables autobinding @todos to @onModelUpdate
      @setModel @todos
      return @localStorage.query @todos

    # parent implementation returns success rusult immediately
    super()

  ###*
    @protected
  ###
  update: ->
    json = @getJsonForTemplate()
    html = este.demos.app.todomvc.todos.templates.element json
    # mergeHtml calls 'este.dom.merge' for partial innerHTML updates
    @mergeHtml html

  ###*
    @return {Object}
    @protected
  ###
  getJsonForTemplate: ->
    length = @todos.getLength()
    remainingCount = @todos.remaining()

    doneCount: length - remainingCount
    filter: @filter
    itemsLocalized: @getLocalizedItems remainingCount
    remainingCount: remainingCount
    todos: @todos.filter @getFilter()
    showMainAndFooter: !!length

  ###*
    @protected
    @return {Object}
  ###
  getFilter: ->
    filter = {}
    switch @filter
      when View.Filter.ACTIVE
        filter['completed'] = false
      when View.Filter.COMPLETED
        filter['completed'] = true
    filter

  ###*
    estejs.tumblr.com/post/35639619128/este-js-localization-cheat-sheet
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
    @desc One item left.
    @protected
  ###
  MSG_ONE_ITEMLEFT: goog.getMsg 'item left'

  ###*
    @desc Zero items left.
    @protected
  ###
  MSG_ZERO_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Two items left.
    @protected
  ###
  MSG_TWO_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Few items left.
    @protected
  ###
  MSG_FEW_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Many items left.
    @protected
  ###
  MSG_MANY_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Other items left.
    @protected
  ###
  MSG_OTHER_ITEMLEFT: goog.getMsg 'items left'