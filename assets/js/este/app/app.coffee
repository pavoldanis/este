###*
  @fileoverview este.App.
###
goog.provide 'este.App'

goog.require 'este.Base'
goog.require 'este.app.Request'
goog.require 'goog.array'
goog.require 'goog.events.EventHandler'

class este.App extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    @pendingRequests = []
    super

  ###*
    @type {Array.<este.app.View>}
  ###
  views: null

  ###*
    @type {Array.<este.app.Request>}
    @protected
  ###
  pendingRequests: null

  ###*
    @param {boolean} silent
  ###
  start: (silent) ->
    return if silent
    @load @views[0]

  ###*
    @param {este.app.View} view
    @param {Object=} params
  ###
  load: (view, params) ->
    request = new este.app.Request view, params
    @pendingRequests.push request
    request.view.load goog.bind @onRequestLoad, @, request

  ###*
    @param {este.app.Request} request
    @param {Object} json
    @protected
  ###
  onRequestLoad: (request, json) ->
    return if !goog.array.contains @pendingRequests, request
    return if !goog.array.peek(@pendingRequests).equal request
    @clearPendingRequests()
    request.view.onLoad json

  ###*
    @protected
  ###
  clearPendingRequests: ->
    @pendingRequests.length = 0

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @clearPendingRequests()
    super
    return