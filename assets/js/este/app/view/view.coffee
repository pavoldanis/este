###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.EventType'

goog.require 'este.app.view.Event'
goog.require 'este.dom.merge'
goog.require 'este.result'
goog.require 'este.router.Route'
goog.require 'este.ui.Component'
goog.require 'goog.string'

class este.app.View extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()

  ###*
    @enum {string}
  ###
  @EventType:
    REDIRECT: 'redirect'

  ###*
    Url has to always start with '/' prefix. If html5 is not supported, then
    urls will be converted to '#/' prefix. If url == '', then view is not url
    projected.
    Various url definitions: este/assets/js/este/router/route_test.coffee
    @type {string}
  ###
  url: ''

  ###*
    @type {este.storage.Local}
  ###
  localStorage: null

  ###*
    todo: refactor
    @type {boolean}
  ###
  html5historyEnabled: true

  ###*
    @type {function(): Object.<string, Function|Array>}
    @protected
  ###
  events: -> {}

  ###*
    @type {Array.<este.Model.Event>} events
    @private
  ###
  unitOfWorkEvents: null

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @return {?string}
  ###
  getUrl: (viewClass, params) ->
    url = viewClass::url
    return null if !url?
    url = este.router.Route.getUrl url, params
    if !@html5historyEnabled
      url = '#/' + url
    url

  ###*
    This method should be overridden by inheriting objects.
    este.storage.Local or este.storage.Rest can be used, or any other object
    implementing goog.result.Result interface. If you don't want to load
    anything, just call default super implementation.
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  load: (params) ->
    este.result.ok params

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @update()
    @registerModelUpdate()
    @registerEvents()
    return

  ###*
    @protected
  ###
  registerModelUpdate: ->
    model = @getModel()
    return if !model || !(model instanceof goog.events.EventTarget)
    @on model, 'update', @onModelUpdateInternal

  ###*
    @param {este.Model.Event} e
    @protected
  ###
  onModelUpdateInternal: (e) ->
    @unitOfWorkEvents.push e

  ###*
    @param {Array.<este.Model.Event>} events
    @protected
  ###
  onModelUpdate: (events) ->

  ###*
    @protected
  ###
  registerEvents: ->
    return if !@events
    for key, value of @events()
      key = goog.string.trim goog.string.normalizeSpaces key
      chunks = key.split ' '
      src = chunks[0]
      type = chunks[1] || value[0]
      fn = if chunks[1] then value else value[1]
      wrapper = @getEventWrapper fn
      @on src, type, wrapper
    return

  ###*
    @param {Function} fn
    @return {Function}
    @protected
  ###
  getEventWrapper: (fn) ->
    (e) ->
      if goog.dom.isElement e.target
        el = @getClientIdElement e
        if el
          clientId = el.getAttribute 'data-cid'
          model = @findModelByClientId clientId
      @unitOfWorkEvents = []
      fn.call @, model, el, e
      @onModelUpdate @unitOfWorkEvents if @unitOfWorkEvents.length

  ###*
    This method should be overridden by inheriting objects. Use this method for
    UI refresh. It's called from enterDocument or on model change.
    @protected
  ###
  update: goog.abstractMethod

  ###*
    Save innerHTML update.
    todo: write and link article about this approach
    @param {string} html
    @protected
  ###
  mergeHtml: (html) ->
    este.dom.merge @getElement(), html

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  redirect: (viewClass, params) ->
    e = new este.app.view.Event View.EventType.REDIRECT, viewClass, params
    @dispatchEvent e

  ###*
    @param {goog.events.BrowserEvent} e
    @return {Element}
    @protected
  ###
  getClientIdElement: (e) ->
    node = goog.dom.getAncestor e.target, (node) ->
      goog.dom.isElement(node) && node.hasAttribute 'data-cid'
    , true
    `/** @type {Element} */ (node)`

  ###*
    @param {*} clientId
    @protected
  ###
  findModelByClientId: (clientId) ->
    for key, value of @
      continue if !(value instanceof este.Collection)
      model = value.findByClientId clientId
      return model if model
    null