###*
  @fileoverview Add several usefull events related features.
  @see ../demos/component.html

  Features
    on/off aliases for getHandler().listen, getHandler().unlisten
    on is allowed only if component is in document (because exitDocument)
    delegate method (event bubbling)
      DOM events
      key (keyHandler)
      focus blur
      tap
      submit

###
goog.provide 'este.ui.Component'

goog.require 'este.dom'
goog.require 'este.events.Delegation'
goog.require 'este.events.SubmitHandler'
goog.require 'este.events.TapHandler'
goog.require 'goog.asserts'
goog.require 'goog.events.KeyHandler'
goog.require 'goog.ui.Component'

class este.ui.Component extends goog.ui.Component

  ###*
    Default implementation of este UI component.
    @param {goog.dom.DomHelper=} domHelper Optional DOM helper.
    @constructor
    @extends {goog.ui.Component}
  ###
  constructor: (domHelper) ->
    super domHelper

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
    @type {este.events.TapHandler}
    @protected
  ###
  tapHandler: null

  ###*
    @type {este.events.SubmitHandler}
    @protected
  ###
  submitHandler: null

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @delegations = []
    @keyHandler = null
    @tapHandler = null
    @submitHandler = null
    return

  ###*
    @inheritDoc
  ###
  exitDocument: ->
    super()
    delegation.dispose() for delegation in @delegations
    @keyHandler?.dispose()
    @tapHandler?.dispose()
    @submitHandler?.dispose()
    return

  ###*
    Just alias for getHandler().listen.
    @param {goog.events.EventTarget|EventTarget|string} src Event source.
    @param {string|Array.<string>|number} type Event type to listen for or array of
      event types or key code number.
    @param {Function|Object=} fn Optional callback function to be used as
      the listener or an object with handleEvent function.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  on: (src, type, fn, capture, handler) ->
    goog.asserts.assert @isInDocument(),
      'on method can be called only when component is in document'
    if goog.isString src
      # todo: add capture, handler args
      @delegate src, type, fn if goog.isFunction fn
      return
    `type = /** @type {string|Array.<string>} */ (type)`
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
    if arg == 'tap'
      @delegateTapEvents selector, fn
    else if arg == 'submit'
      @delegateSubmitEvents selector, fn
    else if typeof arg == 'number'
      @delegateKeyEvents selector, arg, fn
    else
      @delegateDomEvents selector, arg, fn

  ###*
    @param {string} selector
    @param {Function} fn
    @protected
  ###
  delegateTapEvents: (selector, fn) ->
    @tapHandler ?= new este.events.TapHandler @getElement()
    @on @tapHandler, 'tap', (e) ->
      @callDelegateCallbackIfMatched selector, e, fn

  ###*
    @param {string} selector
    @param {Function} fn
    @protected
  ###
  delegateSubmitEvents: (selector, fn) ->
    @submitHandler ?= new este.events.SubmitHandler @getElement()
    @on @submitHandler, 'submit', (e) ->
      @callDelegateCallbackIfMatched selector, e, fn

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
      @callDelegateCallbackIfMatched selector, e, fn

  ###*
    @param {string} selector
    @param {string|Array.<string>} events
    @param {Function} fn
    @protected
  ###
  delegateDomEvents: (selector, events, fn) ->
    matcher = @createSelectorMatcher selector
    delegation = este.events.Delegation.create @getElement(), events, matcher
    @delegations.push delegation
    @on delegation, events, fn

  ###*
    @param {string} selector
    @param {goog.events.BrowserEvent} e
    @param {Function} fn
    @protected
  ###
  callDelegateCallbackIfMatched: (selector, e, fn) ->
    matcher = @createSelectorMatcher selector
    target = goog.dom.getAncestor e.target, matcher, true
    return if !target
    e.target = target
    fn.call @, e

  ###*
    @param {string} selector
    @return {function(Node): boolean}
    @protected
  ###
  createSelectorMatcher: (selector) ->
    (el) -> este.dom.match el, selector