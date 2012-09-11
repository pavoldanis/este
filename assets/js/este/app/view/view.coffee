###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.Event'
goog.provide 'este.app.View.EventType'

goog.require 'este.Base'
goog.require 'este.router.Route'
goog.require 'goog.dom'
goog.require 'goog.events.Event'

class este.app.View extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    super

  ###*
    @enum {string}
  ###
  @EventType:
    REDIRECT: 'redirect'

  ###*
    for example 'detail/:id'
    handle actions via switch
    @type {?string}
  ###
  url: null

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @return {?string}
  ###
  getUrl: (viewClass, params) ->
    url = viewClass::url
    return null if !url?
    este.router.Route.getUrl url, params

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    Can be overriden for async.
    todo: consider deferred object
    @param {goog.result.SimpleResult} result
    @param {Object=} params
  ###
  load: (result, params) ->
    result.setValue params

  ###*
    Called from app onRequestLoad just before layout show.
    todo: consider renaming to parse
    @param {Object} json
  ###
  onLoad: (json) ->
    @render json

  ###*
    Override to render view content.
    @param {Object} json
    @protected
  ###
  render: (json) ->
    # innerHTML = template + viewModel

  ###*
    Override to register events or instantiate short livings object.
  ###
  enterDocument: ->

  ###*
    Override to dispose what were registered or instantied in enterDocument
  ###
  exitDocument: ->
    @getHandler().removeAll()

  ###*
    @return {Element}
  ###
  getElement: ->
    @element ?= document.createElement 'div'

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  redirect: (viewClass, params) ->
    e = new este.app.View.Event viewClass, params
    @dispatchEvent e

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @exitDocument()
    goog.dom.removeNode @element if @element
    super
    return

class este.app.View.Event extends goog.events.Event

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (@viewClass, @params = null) ->
    super este.app.View.EventType.REDIRECT

  ###*
    @type {function(new:este.app.View)}
  ###
  viewClass: ->

  ###*
    @type {Object}
  ###
  params: null