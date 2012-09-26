###*
  @fileoverview Add several usefull events related features.
  @see ../demos/component.html

  Features
    on/off aliases for getHandler().listen, getHandler().unlisten
    on is allowed only when component is in document (because exitDocument)
    delegate method for
      DOM events
      key (keyHandler)
      submit
      focus blur

###
goog.provide 'este.ui.Component'

goog.require 'este.dom'
goog.require 'este.events.Delegation'
goog.require 'goog.asserts'
goog.require 'goog.events.KeyHandler'
goog.require 'goog.ui.Component'

class este.ui.Component extends goog.ui.Component

  ###*
    @constructor
    @extends {goog.ui.Component}
  ###
  constructor: ->
    super

  ###*
    @type {Array.<este.events.Delegation>}
    @protected
  ###
  delegations: null

  ###*
    @type {goog.events.KeyHandler}
    @protected
  ###
  keyHandler: null

  ###*
    @protected
  ###
  enterDocument: ->
    super()
    @delegations = []
    @keyHandler = null
    return

  ###*
    @protected
  ###
  exitDocument: ->
    super()
    delegation.dispose() for delegation in @delegations
    @keyHandler?.dispose()
    return

  ###*
    Just alias for getHandler().listen.
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
    goog.asserts.assert @isInDocument(),
      'on method can be called only when component is in document'
    @getHandler().listen src, type, fn, capture, handler

  ###*
    Just alias for getHandler().unlisten.
    @param {goog.events.EventTarget|EventTarget} src Event source.
    @param {string|Array.<string>} type Event type to listen for or array of
      event types.
    @param {Function|Object=} fn Optional callback function to be used as
      the listener or an object with handleEvent function.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  off: (src, type, fn, capture, handler) ->
    @getHandler().unlisten src, type, fn, capture, handler

  ###*
    @param {string} selector
    @param {string|Array.<string>|number} arg
    @param {Function} fn
    @protected
  ###
  delegate: (selector, arg, fn) ->
    if typeof arg == 'number'
      @delegateKeyEvents selector, arg, fn
    else
      @delegateDomEvents selector, arg, fn

  ###*
    @param {string} selector
    @param {number} keyCode
    @param {Function} fn
    @protected
  ###
  delegateKeyEvents: (selector, keyCode, fn) ->
    @keyHandler ?= new goog.events.KeyHandler @getElement()
    @on @keyHandler, 'key', (e) ->
      return if e.keyCode != keyCode
      target = goog.dom.getAncestor e.target, (el) ->
        este.dom.match el, selector
      , true
      return if !target
      e.target = target
      fn.call @, e

  ###*
    @param {string} selector
    @param {string|Array.<string>} events
    @param {Function} fn
    @protected
  ###
  delegateDomEvents: (selector, events, fn) ->
    delegation = este.events.Delegation.create @getElement(), events, (el) ->
      este.dom.match el, selector
    @delegations.push delegation
    @on delegation, events, fn