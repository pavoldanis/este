###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.Event'
goog.provide 'este.app.View.EventType'

goog.require 'este.Base'
goog.require 'este.result'
goog.require 'este.router.Route'
goog.require 'goog.asserts'
goog.require 'goog.dom'
goog.require 'goog.events.Event'
goog.require 'goog.events.KeyHandler'

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
    Null - no url projection
    empty string - root
    some url - 'detail/:id'
    Handle actions with switch.
    @type {?string}
  ###
  url: null

  ###*
    @type {este.storage.Local}
  ###
  localStorage: null

  ###*
    @type {Element}
    @private
  ###
  element_: null

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
    @element_ ?= document.createElement 'div'

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  redirect: (viewClass, params) ->
    e = new este.app.View.Event viewClass, params
    @dispatchEvent e

  ###*
    @param {goog.events.EventTarget|EventTarget} src Event source.
    @param {string|Array.<string>} type Event type to listen for or array of
      event types.
    @param {Function|Object=} fn Optional callback function to be used as
      the listener or an object with handleEvent function.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  on: (src, type, fn, capture, handler) ->
    goog.asserts.assert @isShown(),
      'ensure you called @on from enterDocument and base method was called'
    super src, type, fn, capture, handler

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @exitDocument()
    if @element_
      goog.dom.removeNode @element_
      @element_ = null
    super
    return

# todo: move to separate file
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