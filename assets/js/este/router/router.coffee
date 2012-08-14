###*
  @fileoverview este.router.Router.
  @see ../demos/router.html

  todo
    use model for routes list, since route path is string and there
    is no reason to have same named paths. Also, it will be save for
    toString etc. routes
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
    @param {string} path
    @param {Function} show
    @param {este.router.Route.Options} options
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
    @param {string} token
  ###
  navigate: (token) ->
    @history.setToken token

  ###*
    @param {string} path
    @param {Object=} params
  ###
  pathNavigate: (path, params) ->
    route = @findRoute path
    return if !route
    @navigate route.getUrl params

  ###*
    @param {string} path
    @protected
  ###
  findRoute: (path) ->
    goog.array.find @routes, (item) ->
      item.path == path

  ###*
    Start routing.
  ###
  start: ->
    @history.setEnabled true
    @getHandler().
      listen(@history, 'navigate', @onHistoryNavigate).
      listen(@tapHandler, 'tap', @onTapHandlerTap)
    return

  ###*
    @param {goog.history.Event} e
    @protected
  ###
  onHistoryNavigate: (e) ->
    @processRoutes e.token

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTapHandlerTap: (e) ->
    token = @tryGetToken e.target
    return if !token
    @history.setToken token

  ###*
    Anchor can be any element with 'este-href' attribute. Classic anchor is not
    sufficient for rich client navigation.
    - native anchors have some nasty behaviour on mobile devices
    - native anchors can't be nested (like anchor in anchor)
    - clickable table rows sucks, tr can't have href
    Why traditional href behaviour isn't overridden? Because sometimes we still
    need classic non-ajax anchors.
    @param {Node} target
    @return {string}
    @protected
  ###
  tryGetToken: (target) ->
    href = ''
    goog.dom.getAncestor target, (node) ->
      return false if node.nodeType != 1
      href = node.getAttribute('este-href') ||
        # for validation zealots
        node.getAttribute('data-este-href')
      !!href
    , true
    href

  ###*
    @param {string} token
    @protected
  ###
  processRoutes: (token) ->
    for route in @routes
      try route.process token
      finally continue
    return

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @history.dispose()
    @tapHandler.dispose()
    super
    return