###*
  @fileoverview este.App.
  todo: add docs and list of demos
###
goog.provide 'este.App'
goog.provide 'este.App.Event'

goog.require 'este.app.Layout'
goog.require 'este.app.Request'
goog.require 'este.app.View'
goog.require 'este.Base'
goog.require 'este.storage.Base'
goog.require 'goog.events.Event'
goog.require 'goog.result'
goog.require 'goog.result.SimpleResult'

class este.App extends este.Base

  ###*
    @param {Array.<este.app.View>} views
    @param {este.app.Layout} layout
    @param {este.Router} router
    @constructor
    @extends {este.Base}
  ###
  constructor: (@views, @layout, @router) ->
    @pendingRequests = []
    super

  ###*
    @enum {string}
  ###
  @EventType:
    BEFORELOAD: 'beforeload'
    BEFORESHOW: 'beforeshow'

  ###*
    JSON from server.
    todo: wait for release new struct and dict annotations to enforce only
    bracket access.
    @type {Object}
  ###
  data: null

  ###*
    @type {este.storage.Base}
  ###
  storage: null

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
    @type {este.Router}
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
    @prepareViews()
    if @urlEnabled
      @startRouter()
    else
      @load @views[0]

  ###*
    @protected
  ###
  prepareViews: ->
    for view in @views
      view.setParentEventTarget @
      view.storage ?= @storage
      view.html5historyEnabled = @router.isHtml5historyEnabled()
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
    result = view.load params
    # todo: implement waitOnError
    goog.result.waitOnSuccess result, =>
      @onViewLoad request

  ###*
    @param {este.app.Request} request
    @protected
  ###
  onViewLoad: (request) ->
    return if !goog.array.contains @pendingRequests, request
    return if !goog.array.peek(@pendingRequests).equal request
    @clearPendingRequests()
    @dispatchAppEvent App.EventType.BEFORESHOW, request
    if @urlEnabled && !request.silent
      url = request.view.getUrl()
      @router.pathNavigate url, request.params, true if url
    @layout.show request.view, request.params

  ###*
    @protected
  ###
  startRouter: ->
    for view in @views
      url = view.getUrl()
      continue if !url
      @router.add url, goog.bind @onRouteMatch, @, view
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
    @param {este.app.view.Event} e
    @protected
  ###
  onRedirect: (e) ->
    view = @findView e.viewClass
    return if !view
    @load view, e.params

  ###*
    @param {function(new:este.app.View)} viewClass
    @return {este.app.View}
    @protected
  ###
  findView: (viewClass) ->
    for view in @views
      return view if view instanceof viewClass
    null

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