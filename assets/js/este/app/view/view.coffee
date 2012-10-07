###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.EventType'

goog.require 'este.app.view.Event'
goog.require 'este.dom.merge'
goog.require 'este.result'
goog.require 'este.router.Route'
goog.require 'este.ui.Component'

class este.app.View extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()
    @deferredTimers = {}

  ###*
    @enum {string}
  ###
  @EventType:
    REDIRECT: 'redirect'

  ###*
    Null - no url projection
    empty string - root
    some url - 'detail/:id'
    Handle actions with switch.
    @type {?string}
  ###
  url: null

  ###*
    @type {este.storage.Local}
  ###
  localStorage: null

  ###*
    @type {Object}
    @private
  ###
  deferredTimers: null

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @return {?string}
  ###
  getUrl: (viewClass, params) ->
    url = viewClass::url
    return null if !url?
    este.router.Route.getUrl url, params

  ###*
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  load: (params) ->
    este.result.ok params

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @update()
    return

  ###*
    Use this method for UI refresh. It's called from enterDocument.
    @protected
  ###
  update: ->
    # innerHTML = template + viewModel

  ###*
    Defer passed method execution after current call stack.
    ex.
      foo = ->
      defer foo
      alert 'ok'
      # foo is called now.
    @param {Function} fn
    @protected
  ###
  defer: (fn) ->
    uid = goog.getUid fn
    clearTimeout @deferredTimers[uid]
    @deferredTimers[uid] = setTimeout =>
      fn.call @
    , 0

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  redirect: (viewClass, params) ->
    e = new este.app.view.Event View.EventType.REDIRECT, viewClass, params
    @dispatchEvent e

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    super()
    clearTimeout value for key, value of @deferredTimers
    return