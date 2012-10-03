###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.EventType'

goog.require 'este.app.view.Event'
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
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  load: (params) ->
    este.result.ok params

  ###*
    onLoad method can be canceled, if another view is shown #lastclickwin
  ###
  onLoad: ->
    # innerHTML = template + viewModel

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
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  redirect: (viewClass, params) ->
    e = new este.app.view.Event View.EventType.REDIRECT, viewClass, params
    @dispatchEvent e