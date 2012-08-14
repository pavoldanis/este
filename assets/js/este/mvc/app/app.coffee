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
    FETCH: 'fetch'
    FETCHED: 'fetched'

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
    @type {este.mvc.View}
    @protected
  ###
  requestedView: null

  ###*
    @param {boolean=} silent
  ###
  start: (silent) ->
    @instantiateViews()
    @showInternal @viewsInstances[0] if !silent

  ###*
    @param {function(new:este.mvc.View)} viewClass
    @param {Object=} params
  ###
  show: (viewClass, params) ->
    for instance in @viewsInstances
      if instance instanceof viewClass
        @showInternal instance, params
        break
    return

  ###*
    @protected
  ###
  instantiateViews: ->
    show = goog.bind @show, @
    @viewsInstances = (for View in @views
      view = new View
      view.show = show
      view)

  ###*
    @param {este.mvc.View} view
    @param {Object=} params
    @protected
  ###
  showInternal: (view, params = null) ->
    # consider: map params to named args
    @requestedView = view
    @dispatchEvent App.EventType.FETCH
    view.fetch params, goog.bind @onViewFetched, @, view, params

  ###*
    @param {este.mvc.View} view
    @param {Object=} params
    @protected
  ###
  onViewFetched: (view, params) ->
    requestedView = @requestedView
    @requestedView = null if view == requestedView
    return if view != requestedView
    @switchView view, params

  ###*
    @param {este.mvc.View} view
    @param {Object=} params
    @protected
  ###
  switchView: (view, params) ->
    @dispatchEvent App.EventType.FETCHED
    @projectUrl view, params
    @layout.setActive view

  ###*
    @param {este.mvc.View} view
    @param {Object=} params
    @protected
  ###
  projectUrl: (view, params) ->
    return if !view.url
    @router.routeNavigate view.url, params

  ###*
    @protected
  ###
  disposeInternal: ->
    super
    @requestedView = null
    return