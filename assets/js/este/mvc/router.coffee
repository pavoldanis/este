###*
  @fileoverview Router.
###

goog.provide 'este.mvc.Router'

goog.require 'goog.events.EventTarget'
goog.require 'goog.events.EventHandler'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'este.History'
goog.require 'goog.debug.Logger'
goog.require 'este.events.TapEventHandler'
goog.require 'goog.uri.utils'

###*
  @param {Object} routes
  @param {boolean=} forceHash If true, este.History will degrade to hash even if html5history is supported
  @constructor
  @extends {goog.events.EventTarget}
###
este.mvc.Router = (@routes, forceHash = false) ->
  @history = new este.History forceHash
  @handler = new goog.events.EventHandler @
  @tapEventHandler = new este.events.TapEventHandler document.body, @targetFilter
  @handler.
    listen(@tapEventHandler, 'tapstart', @onTapStart).
    listen(@tapEventHandler, 'tapend', @onTapEnd).
    listen(@tapEventHandler, 'tap', @onTap).
    listen(@history, 'navigate', @onNavigate)
  @dispatchMatchedRouter()
  return

goog.inherits este.mvc.Router, goog.events.EventTarget
  
goog.scope ->
  `var _ = este.mvc.Router`

  ###*
    @enum {string}
  ###
  _.EventType =
    CHANGE: 'change'

  ###*
    @param {string} path
    @return {string}
  ###
  _.normalize = (path) ->
    if path.charAt(0) in ['/', '#']
      return path.substring 1
    path

  ###*
    @type {Object}
  ###
  _::routes

  ###*
    @type {string} 
  ###
  _::tapHighlightClass = 'tap-highlight'

  ###*
    @type {este.History}
  ###
  _::history

  ###*
    @type {goog.events.EventHandler}
  ###
  _::handler

  ###*
    @type {este.events.TapEventHandler}
  ###
  _::tapEventHandler

  ###*
    @type {string}
  ###
  _::lastPathname

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  _::onTapStart = (e) ->
    goog.dom.classes.add e.target, @tapHighlightClass

    ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  _::onTapEnd = (e) ->
    goog.dom.classes.remove e.target, @tapHighlightClass

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  _::onTap = (e) ->
    # anchors sucks, therefore we use any element with custom attr instead
    # such quasi anchor will not interfere with native behaviour
    # data-hrefs can be nested (anchors cant)
    href = e.target.getAttribute 'data-href'
    pathname =  goog.uri.utils.getPath href
    return if !pathname
    @setPathname pathname
    
  ###*
    @param {string} pathname
  ###
  _::setPathname = (pathname) ->
    pathname = _.normalize pathname
    @history.setToken pathname

  _::targetFilter = (node) ->
    isButton = false
    filteredNode = goog.dom.getAncestor node, (item) ->
      return false if !item.hasAttribute
      isButton = true if item.hasAttribute 'data-button'
      item.hasAttribute 'data-href'
    , true
    return null if isButton
    filteredNode

  ###*
    @protected
  ###
  _::onNavigate = (e) ->
    @dispatchMatchedRouter()

  ###*
    todo: consider try finally dispatching
  ###
  _::dispatchMatchedRouter = ->
    pathname = '/' + _.normalize @history.getToken()
    # chrome for some reason dispatches popstate on page load
    return if @lastPathname? && @lastPathname == pathname
    @lastPathname = pathname
    matched = false
    for routePath, callback of @routes
      if routePath == '*'
        callback()
        continue
      regex = new RegExp "^#{routePath}$"
      match = pathname.match regex
      continue if !match
      @logger_.info 'matched route: ' + routePath
      args = match.slice 1
      args.push =>
        # todo: refactor
        pathname = '/' + _.normalize @history.getToken()
        !!pathname.match regex
      callback.apply null, args
      matched = true
      break;
    if !matched
      @routes['/404']()
    @dispatchEvent _.EventType.CHANGE
    return

  ###*
    @type {goog.debug.Logger}
    @private 
  ###
  _::logger_ = goog.debug.Logger.getLogger 'este.mvc.Router'

  ###*
    @override
  ###
  _::disposeInternal = ->
    @history.dispose()
    @handler.dispose()
    @tapEventHandler.dispose()
    goog.base @, 'disposeInternal'
    return

  return