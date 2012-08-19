###*
  @fileoverview este.mvc.View.
  WARNING: This is still experimental.
###
goog.provide 'este.mvc.View'

goog.require 'este.Base'

class este.mvc.View extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    super()
    @element = document.createElement 'div'

  ###*
    @type {?string}
  ###
  url: null

  ###*
    @type {Function}
  ###
  show: goog.abstractMethod

  ###*
    @type {Element}
  ###
  element: null

  ###*
    Data passed into 'done' method.
    @type {Object}
  ###
  viewData: null

  ###*
    To be overriden.
    todo
      change name? delegate to storage?
      fix brittleness, too easy to override view state
    @param {Object} params
    @param {Function} done
  ###
  fetch: (params, done) ->
    # async ajax call for data
    setTimeout =>
      done params
    , 1

  ###*
    Override to render view content.
  ###
  render: ->
    # @element.innerHTML = 'Hi!'

  ###*
    Override to register listeners. This method is called when element is in
    document.
  ###
  enterDocument: ->
    # @on @getElement(), 'click', @onClick

  ###*
    Remove all registered listeners. This method is called when element is
    removed from DOM.
  ###
  exitDocument: ->
    @getHandler().removeAll()