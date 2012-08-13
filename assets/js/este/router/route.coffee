###*
  @fileoverview este.router.Route.
###
goog.provide 'este.router.Route'

class este.router.Route

  ###*
    @param {string} path
    @param {Function} show
    @param {este.router.Route.Options} options
    @constructor
  ###
  constructor: (@path, @show, options) ->
    @hide ?= options.hide
    @keys = []
    @pathToRegexp options.sensitive, options.strict

  ###*
    @typedef {{
      sensitive: (boolean|undefined),
      strict: (boolean|undefined),
      hide: (Function|undefined)
    }}
  ###
  @Options

  ###*
    @type {string}
  ###
  path: ''

  ###*
    @type {Function}
    @protected
  ###
  show: null

  ###*
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
    @param {Object} params
    @return {string}
  ###
  getPath: (params) ->
    path = @path
    if params.length
      index = 0
      path = path.replace /\*/g, -> params[index++]
    else
      for key, value of params
        value = '' if value == undefined
        regex = new RegExp "\\:#{key}"
        path = path.replace regex, value
    path = path.slice 0, -1 if path.charAt(path.length - 1) == '?'
    path = path.slice 0, -1 if path.charAt(path.length - 1) in ['/', '.']
    path

  ###*
    @param {boolean=} sensitive
    @param {boolean=} strict
    @protected
  ###
  pathToRegexp: (sensitive, strict) ->
    # regexes from expressjs
    regexPath = @path.
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
    @regexp = new RegExp "^#{regexPath}$", if sensitive then '' else 'i'

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