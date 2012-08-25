###*
  @fileoverview este.app.View.
###
goog.provide 'este.app.View'
goog.provide 'este.app.View.Event'

goog.require 'este.Base'
goog.require 'goog.dom'
goog.require 'goog.events.Event'

class este.app.View extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    super

  ###*
    @enum {string}
  ###
  @EventType:
    LOAD: 'load'

  ###*
    for example 'detail/:id'
    @type {?string}
  ###
  url: null

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @param {Function} done
    @param {Object=} params
  ###
  load: (done, params) ->
    # async load example
    # @storage.loadUser params['id'], (user) ->
    #   done user
    # , @fireError()?
    done()

  ###*
    @param {Object} json
  ###
  onLoad: (json) ->
    # innerHTML = template + viewModel

  ###*
    @return {Element}
  ###
  getElement: ->
    @element ||= document.createElement 'div'

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @protected
  ###
  dispatchLoad: (viewClass, params) ->
    event = new este.app.View.Event viewClass, params
    @dispatchEvent event

  ###*
    @inheritDoc
  ###
  disposeInternal: ->
    goog.dom.removeNode @element if @element
    super
    return

class este.app.View.Event extends goog.events.Event

  ###*
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (@viewClass, @params = null) ->
    super este.app.View.EventType.LOAD

  ###*
    @type {?function(new:este.app.View)}
  ###
  viewClass: null

  ###*
    @type {Object}
  ###
  params: null