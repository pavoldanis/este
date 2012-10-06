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
goog.require 'goog.async.Delay'

class este.app.View extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()

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
    @type {goog.async.Delay}
    @private
  ###
  updateDelay_: null

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
    Operations on collection can dispatch many events. We don't want to make
    silent changes, because data consistence is nice. JavaScript is fast, DOM
    is slow, so this method postpone DOM update.
    @protected
  ###
  batchUpdate: ->
    @updateDelay_ ?= new goog.async.Delay @update, 0, @
    @updateDelay_.start()

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
    @updateDelay_.dispose() if @updateDelay_
    super()
    return