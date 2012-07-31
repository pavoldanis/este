###*
  @fileoverview Subclass if you need dispatch or listen events.
###
goog.provide 'este.Base'

goog.require 'goog.events.EventTarget'
goog.require 'goog.events.EventHandler'

class este.Base extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super

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
    @inheritDoc
  ###
  disposeInternal: ->
    @handler_?.dispose()
    super
    return
    
    

