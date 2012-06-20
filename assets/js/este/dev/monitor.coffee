###*
  @fileoverview Dev monitor. Use mlog as console.log.
###
goog.provide 'este.dev.Monitor'
goog.provide 'este.dev.Monitor.create'

goog.require 'goog.ui.Component'

###*
  @constructor
  @extends {goog.ui.Component}
###
este.dev.Monitor = ->
  return

goog.inherits este.dev.Monitor, goog.ui.Component
  
goog.scope ->
  `var _ = este.dev.Monitor`

  _.create = ->
    monitor = new _
    monitor.decorate document.body
    monitor

  ###*
    @type {Element}
  ###
  _::monitor

  ###*
    @type {Node}
  ###
  _::left

  ###*
    @type {Node}
  ###
  _::right

  ###*
    @type {?number}
  ###
  _::timer

  ###*
    @inheritDoc
  ###
  _::decorateInternal = (element) ->
    goog.base @, 'decorateInternal', element
    @monitor = @dom_.createDom 'div'
      # absolute instead of fixed, because obsolete mobile devices
      'style': 'white-space: nowrap; font-size: 10px; position: absolute; z-index: 9999999999999; opacity: .8; max-width: 100%; right: 10px; bottom: 0; background-color: #eee; color: #000; padding: .7em;'
    @left = @monitor.appendChild @dom_.createDom 'div'
      'style': 'word-break: break-word; display: inline-block'
      'id': 'devlog'
    @right = @monitor.appendChild @dom_.createDom 'div'
      'style': 'display: inline-block'
    element.appendChild @monitor
    @timer = setInterval =>
      @right.innerHTML = '| ' + goog.events.getTotalListenerCount()
    , 500
    return

  _::enterDocument = ->
    goog.base @, 'enterDocument'
    @getHandler().
      listen(window, 'scroll', @onWindowScroll)
    return

  _::onWindowScroll = (e) ->
    bottom = -@dom_.getDocumentScroll().y
    @monitor.style.bottom = (bottom + 10) + 'px'

  ###*
    @inheritDoc
  ###
  _::disposeInternal = ->
    clearInterval @timer
    @getElement().removeChild @monitor
    goog.base @, 'disposeInternal'
    return

  window.mlog = ->
    message = goog.array.toArray(arguments).join()
    document.getElementById('devlog').innerHTML = message

  return

