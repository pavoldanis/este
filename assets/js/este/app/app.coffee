###*
  @fileoverview este.App.
###
goog.provide 'este.App'
goog.provide 'este.App.Event'

goog.require 'este.app.Layout'
goog.require 'este.app.Request'
goog.require 'este.app.View'
goog.require 'este.Base'
goog.require 'goog.array'
goog.require 'goog.events.Event'
goog.require 'goog.events.EventHandler'
goog.require 'goog.labs.result.SimpleResult'
goog.require 'goog.labs.result'

class este.App extends este.Base

  ###*
    @param {Array.<este.app.View>} views
    @param {este.app.Layout} layout
    @param {este.router.Router} router
    @constructor
    @extends {este.Base}
  ###
  constructor: (@views, @layout, @router) ->
    @pendingRequests = []
    @prepareViews()
    super

  ###*
    @enum {string}
  ###
  @EventType:
    BEFORELOAD: 'beforeload'
    BEFORESHOW: 'beforeshow'

  ###*
    JSON from server.
    @type {Object}
  ###
  data: null

  ###*
    @type {boolean}
  ###
  urlEnabled: true

  ###*
    @type {Array.<este.app.View>}
    @protected
  ###
  views: null

  ###*
    @type {este.app.Layout}
    @protected
  ###
  layout: null

  ###*
    @type {este.router.Router}
    @protected
  ###
  router: null

  ###*
    @type {Array.<este.app.Request>}
    @protected
  ###
  pendingRequests: null

  ###*
    Start app.
  ###
  start: ->
    @on @, este.app.View.EventType.REDIRECT, @onRedirect
    @startRouter()

  ###*
    @protected
  ###
  prepareViews: ->
    for view in @views
      view.setParentEventTarget @
    return

  ###*
    @param {este.app.View} view
    @param {Object=} params
    @param {boolean=} isNavigation
    @protected
  ###
  load: (view, params, isNavigation) ->
    request = new este.app.Request view, params, isNavigation
    @dispatchAppEvent App.EventType.BEFORELOAD, request
    @pendingRequests.push request
    result = request.load()
    goog.labs.result.waitOnSuccess result, (value) =>
      @onViewLoadCallback request, value

  ###*
    @protected
  ###
  startRouter: ->
    for view in @views
      continue if !view.url?
      @router.add view.url, goog.bind @onRouteMatch, @, view
    @router.silentTapHandler = true
    @router.start()

  ###*
    @param {este.app.View} view
    @param {Object=} params
    @param {boolean=} isNavigation
    @protected
  ###
  onRouteMatch: (view, params, isNavigation) ->
    @load view, params, isNavigation

  ###*
    @param {este.app.View.Event} e
    @protected
  ###
  onRedirect: (e) ->
    view = @lookupView e.viewClass
    return if !view
    @load view, e.params

  ###*
    @param {function(new:este.app.View)} viewClass
    @return {este.app.View}
    @protected
  ###
  lookupView: (viewClass) ->
    for view in @views
      return view if view instanceof viewClass
    null

  ###*
    @param {este.app.Request} request
    @param {Object} json
    @protected
  ###
  onViewLoadCallback: (request, json) ->
    return if !goog.array.contains @pendingRequests, request
    return if !goog.array.peek(@pendingRequests).equal request
    @clearPendingRequests()
    @dispatchAppEvent App.EventType.BEFORESHOW, request
    request.view.onLoad json
    if @urlEnabled && request.view.url? && !request.silent
      @router.pathNavigate request.view.url, request.params, true
    @layout.show request.view, request.params

  ###*
    @param {este.App.EventType} type
    @param {este.app.Request} request
    @protected
  ###
  dispatchAppEvent: (type, request) ->
    e = new App.Event type, request
    @dispatchEvent e

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
    view.dispose() for view in @views
    @layout.dispose()
    @router.dispose()
    super
    return

class este.App.Event extends goog.events.Event

  ###*
    @param {este.App.EventType} type
    @param {este.app.Request} request
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (type, @request) ->
    super type

  ###*
    @type {este.app.Request}
  ###
  request: null