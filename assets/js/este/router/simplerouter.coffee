###*
  @fileoverview este.router.SimpleRouter.
###
goog.provide 'este.router.SimpleRouter'

goog.require 'este.Base'
goog.require 'este.array'

class este.router.SimpleRouter extends este.Base

  ###*
    @param {este.History} history
    @constructor
    @extends {este.Base}
  ###
  constructor: (@history) ->
    super
    @routes = []

  ###*
    @type {este.History}
    @protected
  ###
  history: null

  ###*
    @type {Array.<este.router.Route>}
    @protected
  ###
  routes: null

  ###*
    @param {string|RegExp} path
    @param {Function} show
    @param {este.router.Route.Options} options
  ###
  add: (path, show, options = {}) ->
    route = new este.router.Route path, show, options
    @routes.push route

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

  ###*
    Start routing.
  ###
  start: ->
    @history.setEnabled true
    @getHandler().
      listen(@history, 'navigate', @onHistoryNavigate)
    return

  ###*
    @param {goog.history.Event} e
    @protected
  ###
  onHistoryNavigate: (e) ->
    @processRoutes e.token

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
    super
    return

###*
  @fileoverview este.router.Route.
###
goog.provide 'este.router.Route'

class este.router.Route

  ###*
    @param {string|RegExp} path
    @param {Function} show
    @param {este.router.Route.Options} options
    @constructor
  ###
  constructor: (@path, @show, options) ->
    @hide ?= options.hide
    @keys = []
    @regexp = @pathToRegexp path, options.sensitive, options.strict

  ###*
    @typedef {{
      sensitive: (boolean|undefined),
      strict: (boolean|undefined),
      hide: (Function|undefined)
    }}
  ###
  @Options

  ###*
    @type {string|RegExp}
  ###
  path: null

  ###*
    todo: add signature
    @type {Function}
    @protected
  ###
  show: null

  ###*
    todo: add signature
    @type {Function|undefined}
    @protected
  ###
  hide: null

  ###*
    @type {RegExp}
    @protected
  ###
  regexp: null

  ###*
    @type {Array.<Object>}
    @protected
  ###
  keys: null

  ###*
    @param {string|RegExp} path
    @param {boolean=} sensitive
    @param {boolean=} strict
    @return {RegExp}
    @protected
  ###
  pathToRegexp: (path, sensitive, strict) ->
    return path if path instanceof RegExp
    path = path.
      concat(if strict then '' else '/?').
      replace(/\/\(/g, '(?:/').
      replace(/\+/g, '__plus__').
      replace(/(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?/g,
        (_, slash, format, key, capture, optional) =>
          @keys.push name: key, optional: !!optional
          slash ||= ''
          (if optional then '' else slash) +
          ('(?:') +
          (if optional then slash else '') +
          (format || '') +
          (capture || (format && '([^/.]+?)' || '([^/]+?)')) +
          (')') +
          (optional || '')
        ).
      replace(/([\/.])/g, '\\$1').
      replace(/__plus__/g, '(.+)').
      replace(/\*/g, '(.*)')
    new RegExp "^#{path}$", if sensitive then '' else 'i'

  ###*
    @param {string} path
  ###
  process: (path) ->
    matches = @getMatches path
    if matches
      params = @getParams matches
      @show params
      return
    @hide() if @hide

  ###*
    @param {string} path
    @return {Array.<string>}
    @protected
  ###
  getMatches: (path) ->
    qsIndex = path.indexOf '?'
    pathname = if qsIndex > -1 then path.slice(0, qsIndex) else path
    @regexp.exec pathname

  ###*
    @param {Array.<string>} matches
    @return {Array}
    @protected
  ###
  getParams: (matches) ->
    params = []
    for match, i in matches
      continue if !i
      key = @keys[i - 1]
      value = if typeof(match) == 'string'
        decodeURIComponent match
      else
        match
      if key
        params[key.name] ?= value
      else
        params.push value
    params