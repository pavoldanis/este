###*
  @fileoverview visionmedia/page.js for Google Closure.
  @deprecated It was just an experiment.
###
goog.provide 'este.Page'

###*
  @param {string=} base
  @constructor
###
este.Page = (@base = '') ->
  @callbacks = []
  return

goog.scope ->
  `var _ = este.Page`

  ###*
    @type {string}
    @protected
  ###
  _::base = ''

  ###*
    @type {boolean}
    @protected
  ###
  _::dispatch = true

  ###*
    @type {boolean}
    @protected
  ###
  _::running = false

  ###*
    @type {Array.<Function>}
    @protected
  ###
  _::callbacks

  ###*
    @param {string} path
    @param {(Function|Array.<Function>)} fns
  ###
  _::add = (path, fns) ->
    route = new este.Page.Route path
    fns = [fns] if typeof fns == 'function'
    @callbacks.push route.middleware fn for fn in fns

  ###*
    @param {boolean=} dispatch perform initial dispatch
  ###
  _::start = (@dispatch = true) ->
    return if @running || !@dispatch
    @running = true
    @replace location.pathname + location.search, null, true, @dispatch

  ###*
    Replace path with optional state object.
    @param {string} path
    @param {Object} state
    @param {boolean} init
    @param {boolean} dispatch
    @return {este.Page.Context}
  ###
  _::replace = (path, state, init, dispatch = true) ->
    ctx = new este.Page.Context @base, path, state
    ctx.init = init
    @dispatchContext ctx if dispatch
    ctx.save()
    ctx

  ###*
    Dispatch the given ctx.
    @param {este.Page.Context} context
  ###
  _::dispatchContext = (context) ->
    i = 0
    do next = =>
      fn = @callbacks[i++]
      return @unhandled context if !fn
      fn context, next
  
  ###*
    Unhandled context. When it's not the initial popstate then redirect. If you wish to handle 404s on your own use page('*', callback).
    @param {este.Page.Context} context
    @protected
  ###
  _::unhandled = (context) ->
    return if window.location.pathname == context.canonicalPath
    @stop()
    context.unhandled = true
    window.location = context.canonicalPath

  ###*
    todo: Unbind click and popstate event handlers.
  ###
  _::stop = ->
    @running = false

  ###*
    Show path with optional state object.
    @param {string} path
    @param {Object} state
    @return {este.Page.Context}
  ###
  _::show = (path, state) ->
    context = new este.Page.Context @base, path, state
    @dispatchContext context
    context.pushState() if !context.unhandled
    context

  return

###*
  Initialize Route with the given HTTP path, and an array of callbacks and options.
  @param {string} path
  @param {boolean=} sensitive enable case-sensitive routes
  @param {boolean=} strict enable strict matching for trailing slashes
  @constructor
###
este.Page.Route = (@path, @sensitive = false, @strict = false) ->
  @keys = []
  @regExp = @pathToRegExp @path
  return

goog.scope ->
  `var _ = este.Page.Route`

  ###*
    @type {string}
  ###
  _::method = 'GET'

  ###*
    @type {string}
  ###
  _::path

  ###*
    @type {boolean}
  ###
  _::sensitive

  ###*
    @type {boolean}
  ###
  _::strict

  ###*
    @type {Array}
    @protected
  ###
  _::keys

  ###*
    @type {RegExp}
    @protected
  ###
  _::regExp

  ###*
    @param {(string|RegExp|Array)} path
    @protected
    @return {RegExp}
  ###
  _::pathToRegExp = (path) ->
    return path if path instanceof RegExp
    path = "(#{path.join '|'})" if path instanceof Array
    path = path.concat((if @strict then '' else '/?')).
      replace(/\/\(/g, '(?:/').
      replace(/\+/g, '__plus__').
      replace(/(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?/g,
        (_, slash, format, key, capture, optional) =>
          @keys.push
            name: key
            optional: !!optional
          slash ||= ''
          '' +
            (if optional then '' else slash) +
            '(?:' + (if optional then slash else '') +
            (format || '') +
            (capture || (format || '([^/.]+?)' || '([^/]+?)')) + ')' +
            (optional || '')).
      replace(/([\/.])/g, '\\$1').
      replace(/__plus__/g, '(.+)').
      replace(/\*/g, '(.*)')
    
    new RegExp "^#{path}$", if @sensitive then '' else 'i'

  ###*
    Return route middleware with the given callback fn().
    @param {Function} fn
    @return {Function}
  ###
  _::middleware = (fn) ->
    (context, next) =>
      return fn context, next if @match context.path, context.params
      next()

  ###*
    Check if this route matches path, if so populate params.
    @param {string} path
    @param {Array} params
    @return {boolean}
    @protected
  ###
  _::match = (path, params) ->
    qsIndex = path.indexOf '?'
    pathname = if ~qsIndex then path.slice(0, qsIndex) else path
    matches = @regExp.exec pathname
    return false if !matches
    
    i = 1
    len = matches.length

    while i < len
      key = @keys[i - 1]
      val = matches[i]
      val = decodeURIComponent val if typeof matches[i] == 'string'
      if key
        params[key.name] ?= val
      else
        params.push val
      i++
    true

  return


###*
  Initialize a new request Context with the given path and optional initial state.
  @param {string} base
  @param {string} path
  @param {Object} state
  @constructor
###
este.Page.Context = (base, path, state) ->
  path = base + path if '/' == path[0] && 0 != path.indexOf base
  i = path.indexOf '?'
  @canonicalPath = path
  @path = path.replace(base, '') || '/'
  @title = document.title
  @state = state || {}
  @state.path = path
  @querystring = if ~i then path.slice(i + 1) else ''
  @pathname = if ~i then path.slice(0, i) else path
  @params = []
  return

goog.scope ->
  `var _ = este.Page.Context`

  ###*
    @type {string}
  ###
  _::canonicalPath

  ###*
    @type {string}
  ###
  _::path

  ###*
    @type {string}
  ###
  _::title

  ###*
    @type {Object}
  ###
  _::state

  ###*
    @type {string}
  ###
  _::querystring

  ###*
    @type {string}
  ###
  _::pathname

  ###*
    @type {Array}
  ###
  _::params

  ###*
    @type {boolean}
  ###
  _::unhandled = false

  _::pushState = ->
    window.history.pushState @state, @title, @canonicalPath

  _::save = ->
    window.history.replaceState @state, @title, @canonicalPath

  return













