###*
  @fileoverview este.router.Router.
  @see ../demos/router.html

  Navigation element is any element with 'href' attribute. Not only anchor, but
  li or tr too. Of course only <a href='..'s are crawable with search engines.
  But if we are creating pure client side rendered web app, we can use 'href'
  attribute on any element we need. We can even nest anchors, which is very
  useful for touch devices.
###
goog.provide 'este.router.Router'

goog.require 'este.Base'
goog.require 'este.array'
goog.require 'este.router.Route'
goog.require 'goog.dom'

class este.router.Router extends este.Base

  ###*
    @param {este.History} history
    @param {este.events.TapHandler} tapHandler
    @constructor
    @extends {este.Base}
  ###
  constructor: (@history, @tapHandler) ->
    super
    @routes = []

  ###*
    If true, tapHandler will not change url.
    todo: add docs
    @type {boolean}
  ###
  silentTapHandler: false

  ###*
    @type {este.History}
    @protected
  ###
  history: null

  ###*
    @type {este.events.TapHandler}
    @protected
  ###
  tapHandler: null

  ###*
    @type {Array.<este.router.Route>}
    @protected
  ###
  routes: null

  ###*
    @type {boolean}
    @protected
  ###
  ignoreNextOnHistoryNavigate: false

  ###*
    @param {string} path
    @param {Function} show
    @param {este.router.Route.Options=} options
    @return {este.router.Router}
  ###
  add: (path, show, options = {}) ->
    route = new este.router.Route path, show, options
    @routes.push route
    @

  ###*
    @param {string|RegExp} path
    @return {boolean}
  ###
  remove: (path) ->
    este.array.removeAllIf @routes, (item) ->
      item.path == path

  ###*
    @param {string} path
    @param {Object=} params
    @param {boolean=} silent
  ###
  pathNavigate: (path, params, silent = false) ->
    route = @findRoute path
    return if !route
    @ignoreNextOnHistoryNavigate = silent
    @navigate route.getUrl params

  ###*
    @param {string} path
    @protected
  ###
  findRoute: (path) ->
    goog.array.find @routes, (item) -> item.path == path

  ###*
    @param {string} token
  ###
  navigate: (token) ->
    # console.log token
    @history.setToken token

  ###*
    Start router.
  ###
  start: ->
    @on @tapHandler.getElement(), 'click', @onTapHandlerElementClick
    @on @tapHandler, 'tap', @onTapHandlerTap
    @on @history, 'navigate', @onHistoryNavigate
    @history.setEnabled true
    return

  ###*
    todo: ignore unmatched tokens
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTapHandlerElementClick: (e) ->
    token = @tryGetToken e.target
    return if !token
    e.preventDefault()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTapHandlerTap: (e) ->
    token = @tryGetToken e.target
    return if !token
    if @silentTapHandler
      @processRoutes token, false
      return
    @history.setToken token

  ###*
    @param {goog.history.Event} e
    @protected
  ###
  onHistoryNavigate: (e) ->
    if @ignoreNextOnHistoryNavigate
      @ignoreNextOnHistoryNavigate = false
      return
    @processRoutes e.token, e.isNavigation

  ###*
    @param {Node} target
    @return {string}
    @protected
  ###
  tryGetToken: (target) ->
    token = ''
    goog.dom.getAncestor target, (node) ->
      return false if node.nodeType != 1
      token = node.getAttribute 'href'
    , true
    token

  ###*
    @param {string} token
    @param {boolean} isNavigation
    @protected
  ###
  processRoutes: (token, isNavigation) ->
    firstRouteMatched = false
    for route in @routes
      try
        matched = route.process token, isNavigation, firstRouteMatched
        firstRouteMatched = true if matched
      finally
        continue
    return

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @history.dispose()
    @tapHandler.dispose()
    super
    return