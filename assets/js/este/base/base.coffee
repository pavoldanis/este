###*
  @fileoverview Base class for classes using events.
###
goog.provide 'este.Base'

goog.require 'goog.asserts'
goog.require 'goog.events.EventHandler'
goog.require 'goog.events.EventTarget'

class este.Base extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()

  ###*
    @type {goog.events.EventHandler}
    @private
  ###
  handler_: null

  ###*
    @protected
  ###
  getHandler: ->
    @handler_ ?= new goog.events.EventHandler @

  ###*
    Just alias for .listen.
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
    @getHandler().listen src, type, fn, capture, handler

  ###*
    Just alias for .unlisten.
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
    Something like setParentEventTarget, but this implementation allows more
    parents.
    @param {boolean} toggle
    @param {Array.<string>} eventTypes
    @param {goog.events.EventTarget} eventTarget
    @protected
  ###
  toggleEventPropagation: (toggle, eventTypes, eventTarget) ->
    if toggle
      @on eventTarget, eventTypes, @dispatchEvent
    else
      @off eventTarget, eventTypes, @dispatchEvent

  ###*
    @override
  ###
  disposeInternal: ->
    @handler_?.dispose()
    super
    return