###*
  @fileoverview Este Mvc App.

  todo doc
    how to create app (subclass)
    manages views states
    compile time safe app states transitions
    url routing is optional
    last click win technique
    layout

  WARNING: This is still experimental.
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
    @param {boolean=} silent
  ###
  start: (silent) ->
    @instantiateViews()
    return if silent
    @router.start()
    # request = new este.mvc.app.Request @viewsInstances[0]
    # @showInternal request

  ###*
    @param {function(new:este.mvc.View)} viewClass
    @param {Object=} params
  ###
  show: (viewClass, params) ->
    for instance in @viewsInstances
      if instance instanceof viewClass
        request = new este.mvc.app.Request instance, params
        @showInternal request
        break
    return

  ###*
    todo: split it into two methods
    @protected
  ###
  instantiateViews: ->
    show = goog.bind @show, @
    @viewsInstances = []
    for View in @views
      view = new View
      view.show = show
      if view.url?
        @router.add view.url, goog.bind @onRouterShow, @, view
      @viewsInstances.push view
    return

  ###*
    @param {este.mvc.View} view
    @param {Object|Array} params
    @protected
  ###
  onRouterShow: (view, params) ->
    request = new este.mvc.app.Request view, params
    # console.log 'onRouterShow', view, params
    @showInternal request

  ###*
    @param {este.mvc.app.Request} request
    @protected
  ###
  showInternal: (request) ->
    # consider: map params to named args
    @lastRequest = request
    @dispatchEvent App.EventType.BEFORE_VIEW_SHOW
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
    request.setViewData response
    @switchView request

  ###*
    @param {este.mvc.app.Request} request
    @protected
  ###
  switchView: (request) ->
    if request.view.url?
      @router.pathNavigate request.view.url, request.params
    @layout.setActive request.view, request.params
    @dispatchEvent App.EventType.AFTER_VIEW_SHOW

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    super
    @lastRequest = null
    return