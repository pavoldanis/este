###*
  @fileoverview este.mvc.View.
  todo
    add url projection
    use data store for CRUD
      ds.fetch app.user.Model, 3
    async
  WARNING: This is still highly experimental.
###
goog.provide 'este.mvc.View'

goog.require 'este.Base'

class este.mvc.View extends este.Base

  ###*
    @param {Function} show
    @param {Element=} element
    @constructor
    @extends {este.Base}
  ###
  constructor: (@show, element) ->
    super
    @element = element ? document.createElement 'div'

  ###*
    @type {Function}
    @protected
  ###
  show: null

  ###*
    @type {Element}
  ###
  element: null

  ###*
    @type {Object}
    @protected
  ###
  params: null

  ###*
    To be overriden.
    @param {Object} params
    @param {Function} done
  ###
  fetch: (@params, done) ->
    done()

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