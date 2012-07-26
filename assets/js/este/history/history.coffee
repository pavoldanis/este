###*
  @fileoverview HTML5 pushState and hashchange history.
  Facade for goog.History and goog.history.Html5History.
  It dispatches goog.history.Event.
###

goog.provide 'este.History'

goog.require 'goog.History'
goog.require 'goog.history.Html5History'
goog.require 'goog.history.Event'
goog.require 'goog.events.EventTarget'
goog.require 'goog.events.EventHandler'
goog.require 'goog.dom'
goog.require 'este.mobile'
goog.require 'este.history.TokenTransformer'

###*
  @param {boolean=} forceHash If true, este.History will degrade to hash even
  if html5history is supported.
  @param {string=} pathPrefix Path prefix to use if storing tokens in the path.
  The path prefix should start and end with slash.
  @constructor
  @extends {goog.events.EventTarget}
###
este.History = (forceHash, @pathPrefix) ->
  goog.base @
  
  html5historySupported = goog.history.Html5History.isSupported()
  # iOS < 5 does not support pushState correctly
  if este.mobile.iosVersion && este.mobile.iosVersion < 5
    html5historySupported = false

  @html5historyEnabled = html5historySupported && !forceHash
  @setHistoryInternal pathPrefix || '/'
  return

goog.inherits este.History, goog.events.EventTarget
  
goog.scope ->
  `var _ = este.History`

  ###*
    @type {boolean}
  ###
  _::html5historyEnabled

  ###*
    @type {goog.History|goog.history.Html5History}
    @protected
  ###
  _::history

  ###*
    @type {goog.events.EventHandler}
    @protected
  ###
  _::handler

  ###*
    @type {boolean}
    @protected
  ###
  _::silent = false

  ###*
    @param {string} token
    @param {boolean=} silent
  ###
  _::setToken = (token, @silent = false) ->
    @history.setToken token

  ###*
    @return {string}
  ###
  _::getToken = ->
    @history.getToken()

  ###*
    @param {boolean=} enabled
  ###
  _::setEnabled = (enabled = true) ->
    @handler ?= new goog.events.EventHandler @
    if enabled
      @handler.listen @history, 'navigate', @onNavigate
    else
      @handler.unlisten @history, 'navigate', @onNavigate
    @history.setEnabled enabled

  ###*
    @param {string} pathPrefix
    @protected
  ###
  _::setHistoryInternal = (pathPrefix) ->
    if @html5historyEnabled
      transformer = new este.history.TokenTransformer()
      @history = new goog.history.Html5History undefined, transformer
      @history.setUseFragment false
      @history.setPathPrefix pathPrefix
    else
      # workaround: hidden input created in history via doc.write does not work
      input = goog.dom.createDom 'input', style: 'display: none'
      `input = /** @type {HTMLInputElement} */ (input)`
      document.body.appendChild input
      @history = new goog.History false, undefined, input

  ###*
    @param {goog.history.Event} e
    @protected
  ###
  _::onNavigate = (e) ->
    if @silent
      @silent = false
      return
    @dispatchEvent e

  ###*
    @override
  ###
  _::disposeInternal = ->
    @history?.dispose()
    @handler?.dispose()
    goog.base @, 'disposeInternal'
    return

  return

