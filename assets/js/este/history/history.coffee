###*
  @fileoverview HTML5 pushState and hashchange history.
  Facade for goog.History and goog.history.Html5History.
  It dispatches goog.history.Event.
  @see ../demos/history.html
###

goog.provide 'este.History'

goog.require 'este.Base'
goog.require 'este.history.TokenTransformer'
goog.require 'este.mobile'
goog.require 'goog.History'
goog.require 'goog.dom'
goog.require 'goog.history.Event'
goog.require 'goog.history.Html5History'
goog.require 'goog.userAgent.product.isVersion'

class este.History extends este.Base

  ###*
    @param {string=} pathPrefix Path prefix to use if storing tokens in the path.
    The path prefix should start and end with slash.
    @param {boolean=} forceHash If true, este.History will degrade to hash even
    if html5history is supported.
    @constructor
    @extends {este.Base}
  ###
  constructor: (@pathPrefix, forceHash) ->
    super
    html5historySupported = goog.history.Html5History.isSupported()

    # iOS < 5 does not support pushState correctly
    if este.mobile.iosVersion && este.mobile.iosVersion < 5
      html5historySupported = false

    # Android 2.x is forced to use hash-based history due to a bug in Android's
    # HTML5 history implementation. This bug does not affect Android 3.0 and
    # higher.
    if goog.userAgent.product.ANDROID && !goog.userAgent.product.isVersion 3
      html5historySupported = false

    @html5historyEnabled = html5historySupported && !forceHash
    @setHistoryInternal pathPrefix ? '/'

  ###*
    @type {boolean}
  ###
  html5historyEnabled: true

  ###*
    @type {goog.History|goog.history.Html5History}
    @protected
  ###
  history: null

  ###*
    @type {goog.events.EventHandler}
    @protected
  ###
  handler: null

  ###*
    @type {boolean}
    @protected
  ###
  silent: false

  ###*
    @param {string} token
    @param {boolean=} silent
  ###
  setToken: (token, @silent = false) ->
    @history.setToken token

  ###*
    @return {string}
  ###
  getToken: ->
    @history.getToken()

  ###*
    @param {boolean=} enabled
  ###
  setEnabled: (enabled = true) ->
    if enabled
      @getHandler().listen @history, 'navigate', @onNavigate
    else
      @getHandler().unlisten @history, 'navigate', @onNavigate
    @history.setEnabled enabled

  ###*
    @param {string} pathPrefix
    @protected
  ###
  setHistoryInternal: (pathPrefix) ->
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
  onNavigate: (e) ->
    if @silent
      @silent = false
      return
    @dispatchEvent e

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    @history.dispose()
    super
    return