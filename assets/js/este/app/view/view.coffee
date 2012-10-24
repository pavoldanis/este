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
goog.require 'goog.i18n.pluralRules'

class este.app.View extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()
    @deferredTimers = {}

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
    @type {boolean}
  ###
  html5historyEnabled: true

  ###*
    @type {Object}
    @private
  ###
  deferredTimers: null

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
    This method should be overridden by inheriting objects.
    Use this method for UI refresh. It can be called from enterDocument or on
    model change.
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
    Defer passed method execution after current call stack.
    ex.
      defer -> alert 'second'
      alert 'first'
    todo: refactor into este.functions.defer
    @param {Function} fn
    @protected
  ###
  defer: (fn) ->
    uid = goog.getUid fn
    clearTimeout @deferredTimers[uid]
    @deferredTimers[uid] = setTimeout =>
      fn.call @
    , 0

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  redirect: (viewClass, params) ->
    e = new este.app.view.Event View.EventType.REDIRECT, viewClass, params
    @dispatchEvent e

  ###*
    @inheritDoc
  ###
  on: (src, type, fn, capture, handler) ->
    oldFn = fn
    fn = (e) =>
      model = null
      if goog.dom.isElement e.target
        clientIdElement = @getClientIdElement e
        if clientIdElement
          clientId = clientIdElement.getAttribute 'client-id'
          model = @findModelByClientId clientId
          if model
            e.model = model
            e.modelElement = clientIdElement
      oldFn.apply @, arguments
    super src, type, fn, capture, handler

  ###*
    @param {goog.events.BrowserEvent} e
    @return {Element}
    @protected
  ###
  getClientIdElement: (e) ->
    node = goog.dom.getAncestor e.target, (node) ->
      goog.dom.isElement(node) && node.hasAttribute 'client-id'
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

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    super()
    clearTimeout value for key, value of @deferredTimers
    return