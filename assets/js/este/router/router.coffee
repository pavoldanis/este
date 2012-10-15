###*
  @fileoverview este.router.Router.
  @see ../demos/router.html

  Anchor can be any element with 'e-href' attribute. Classic anchor is not
    sufficient for rich client navigation.
    - native anchors have some nasty behaviour on mobile devices
    - native anchors can't be nested (like anchor in anchor)
    - clickable table rows sucks, tr can't have href
    Why traditional href behaviour isn't overridden? Because sometimes we still
    need classic non-ajax anchors.
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
    @param {string} token
  ###
  navigate: (token) ->
    @history.setToken token

  ###*
    Start router. It dispatched
  ###
  start: ->
    @getHandler().
      listen(@history, 'navigate', @onHistoryNavigate).
      listen(@tapHandler, 'tap', @onTapHandlerTap)
    @history.setEnabled true
    return

  ###*
    @param {string} path
    @protected
  ###
  findRoute: (path) ->
    goog.array.find @routes, (item) ->
      item.path == path

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
    @param {Node} target
    @return {string}
    @protected
  ###
  tryGetToken: (target) ->
    href = ''
    goog.dom.getAncestor target, (node) ->
      return false if node.nodeType != 1
      href = node.getAttribute 'e-href'
      !!href
    , true
    href

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