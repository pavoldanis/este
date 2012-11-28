###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.EventType'

goog.require 'este.app.view.Event'
goog.require 'este.Collection'
goog.require 'este.dom.merge'
goog.require 'este.result'
goog.require 'este.router.Route'
goog.require 'este.ui.Component'

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
    @type {este.storage.Base}
  ###
  storage: null

  ###*
    todo: refactor
    @type {boolean}
  ###
  html5historyEnabled: true

  ###*
    Url has to always start with '/' prefix. If html5 is not supported, then
    urls will be converted to '#/' prefix. If url == '', then view is not url
    projected.
    Various url definitions: este/assets/js/este/router/route_test.coffee
    @type {string|function(): string}
    @protected
  ###
  url: -> ''

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @return {?string}
  ###
  createUrl: (viewClass, params) ->
    url = viewClass::url
    url = url() if goog.isFunction url
    return null if !url?
    url = este.router.Route.getUrl url, params
    if !@html5historyEnabled
      url = '#/' + url
    url

  ###*
    @return {string}
  ###
  getUrl: ->
    url = @url
    url = url() if goog.isFunction url
    url

  ###*
    Load method has to return object implementing goog.result.Result interface.
    This method should be overridden.
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
    @events()
    return

  ###*
    Use this method for UI refresh. It's called from enterDocument or on model
    change. This method should be overridden.
    @protected
  ###
  update: ->

  ###*
    Use this method for event registration. This method should be overridden.
    @protected
  ###
  events: ->

  ###*
    @inheritDoc
  ###
  delegateType: (selector, type, fn, el) ->
    fn = @getDelegatedEventWrapper fn
    super selector, type, fn, el

  ###*
    @param {Function} fn
    @return {Function}
    @protected
  ###
  getDelegatedEventWrapper: (fn) ->
    (e) ->
      if goog.dom.isElement e.target
        el = @getClientIdElement e
        if el
          clientId = el.getAttribute 'data-cid'
          model = @findModelByClientId clientId
      @beforeDelegatedEventAction()
      if model
        fn.call @, model, el, e
      else
        fn.call @, e
      @afterDelegatedEventAction()

  ###*
    @protected
  ###
  beforeDelegatedEventAction: ->
    @storage.openSession()

  ###*
    @protected
  ###
  afterDelegatedEventAction: ->
    result = @storage.saveChanges()
    goog.result.wait result, @onStorageSaveChanges, @

  ###*
    @param {!goog.result.Result} result
    @protected
  ###
  onStorageSaveChanges: (result) ->
    switch result.getState()
      when goog.result.Result.State.SUCCESS
        @onSaveSuccess()
      when goog.result.Result.State.ERROR
        @onSaveError()

  ###*
    @protected
  ###
  onSaveSuccess: ->
    @update()

  ###*
    @protected
  ###
  onSaveError: ->
    alert 'todo'

  ###*
    Merge innerHTML via DOM methods. Only changed elements are updated.
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
    @param {string} clientId
    @protected
  ###
  findModelByClientId: (clientId) ->
    for key, value of @
      continue if !(value instanceof este.Collection)
      model = value.findByClientId clientId
      return model if model
    null