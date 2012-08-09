###*
  @fileoverview este.View.
  todo
    add url projection
    use data store for CRUD
      ds.load app.user.Model, 3
    async
  WARNING: This is still highly experimental.
###
goog.provide 'este.View'

goog.require 'este.Base'

class este.View extends este.Base

  ###*
    @param {Element=} element
    @constructor
    @extends {este.Base}
  ###
  constructor: (element) ->
    super
    @element_ = element ? document.createElement 'div'

  ###*
    @enum {string}
  ###
  @EventType:
    LOADING: 'loading'
    LOADED: 'loaded'

  ###*
    @type {Element}
    @private
  ###
  element_: null

  ###*
    @return {Element}
  ###
  getElement: ->
    @element_

  ###*
    @protected
  ###
  dispatchLoadingEvent: ->
    @dispatchEvent View.EventType.LOADING

  ###*
    @protected
  ###
  dispatchLoadedEvent: ->
    @dispatchEvent View.EventType.LOADED