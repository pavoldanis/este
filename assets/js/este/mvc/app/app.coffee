###*
  @fileoverview Este Mvc App.
  Beta.
###
goog.provide 'este.mvc.App'

goog.require 'este.Base'
goog.require 'este.mvc.app.Request'

class este.mvc.App extends este.Base

  ###*
    @param {este.mvc.Layout} layout
    @param {Array.<function(new:este.mvc.View)>} views
    @param {este.router.Router} router
    @constructor
    @extends {este.Base}
  ###
  constructor: (@layout, @views, @router) ->
    super

  ###*
    @enum {string}
  ###
  @EventType:
    BEFORE_VIEW_SHOW: 'beforeviewshow'
    AFTER_VIEW_SHOW: 'afterviewshow'

  ###*
    Server side JSON configuration and seed data injected into page.
    @type {Object}
  ###
  data: null

  ###*
    @type {boolean}
  ###
  urlProjectionEnabled: true

  ###*
    @type {este.mvc.Layout}
    @protected
  ###
  layout: null

  ###*
    @type {Array.<function(new:este.mvc.View)>}
    @protected
  ###
  views: null

  ###*
    @type {este.router.Router}
    @protected
  ###
  router: null

  ###*
    @type {Array.<este.mvc.View>}
    @protected
  ###
  viewsInstances: null

  ###*
    @type {este.mvc.app.Request}
    @protected
  ###
  lastRequest: null

  ###*
    Start application. If urlProjectionEnabled == true, then matched route view
    is shown, otherwise first view in .views array is shown.
  ###
  start: ->
    @prepareViews()
    if @urlProjectionEnabled
      @router.start()
    else
      request = new este.mvc.app.Request @viewsInstances[0]
      @showInternal request

  ###*
    @param {function(new:este.mvc.View)} viewClass
    @param {Object=} params
  ###
  show: (viewClass, params) ->
    instance = @findViewInstance viewClass
    # throw exception?
    return if !instance
    request = new este.mvc.app.Request instance, params
    @showInternal request

  ###*
    @protected
  ###
  prepareViews: ->
    @instantiateViews()
    @setViewsShowMethod()
    @addViewsToRouter() if @urlProjectionEnabled

  ###*
    @protected
  ###
  instantiateViews: ->
    @viewsInstances = (new view for view in @views)

  ###*
    @protected
  ###
  setViewsShowMethod: ->
    show = goog.bind @show, @
    instance.show = show for instance in @viewsInstances
    return

  ###*
    @protected
  ###
  addViewsToRouter: ->
    for view in @viewsInstances
      continue if !view.url?
      matchedBound = goog.bind @onRouterRouteMatched, @, view
      @router.add view.url, matchedBound
    return

  ###*
    @param {este.mvc.View} view
    @param {Object|Array} params
    @protected
  ###
  onRouterRouteMatched: (view, params) ->
    request = new este.mvc.app.Request view, params, true
    @showInternal request

  ###*
    @param {function(new:este.mvc.View)} viewClass
    @return {este.mvc.View}
    @protected
  ###
  findViewInstance: (viewClass) ->
    for instance in @viewsInstances
      return instance if instance instanceof viewClass
    null

  ###*
    @param {este.mvc.app.Request} request
    @protected
  ###
  showInternal: (request) ->
    @lastRequest = request
    @dispatchEvent
      type: App.EventType.BEFORE_VIEW_SHOW
      request: request
    request.fetch goog.bind @onViewFetched, @

  ###*
    @param {este.mvc.app.Request} request
    @param {Object} response
    @protected
  ###
  onViewFetched: (request, response) ->
    lastRequest = @lastRequest
    @lastRequest = null if request.equal lastRequest
    return if !request.equal lastRequest
    @switchView request, response

  ###*
    @param {este.mvc.app.Request} request
    @param {Object} response
    @protected
  ###
  switchView: (request, response) ->
    request.setViewData response
    if request.view.url? && !request.silent
      @router.pathNavigate request.view.url, request.params, true
    @layout.setActive request.view, request.params
    @dispatchEvent
      type: App.EventType.AFTER_VIEW_SHOW
      request: request

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @lastRequest = null
    super
    return