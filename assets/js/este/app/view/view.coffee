###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.Event'
goog.provide 'este.app.View.EventType'

goog.require 'este.Base'
goog.require 'este.result'
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
    @type {este.storage.Local}
  ###
  localStorage: null

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {boolean}
    @protected
  ###
  isShown_: false

  ###*
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  load: (params) ->
    este.result.ok params

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
    Render view.
  ###
  render: ->
    # innerHTML = template + viewModel

  ###*
    @return {boolean}
  ###
  isShown: ->
    @isShown_

  ###*
    Override to register events or instantiate short livings object.
  ###
  enterDocument: ->
    @isShown_ = true

  ###*
    Override to dispose what were registered or instantied in enterDocument
  ###
  exitDocument: ->
    @isShown_ = false
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
  on: (src, type, fn, capture, handler) ->
    if !@isShown()
      throw Error 'move your @on into enterDocument method'
    super src, type, fn, capture, handler

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