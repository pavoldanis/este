###*
  @fileoverview este.app.view.Event.
###
goog.provide 'este.app.view.Event'

goog.require 'goog.events.Event'

class este.app.view.Event extends goog.events.Event

  ###*
    @param {string} type
    @param {function(new:este.app.View)} viewClass
    @param {Object=} params
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (type, @viewClass, @params = null) ->
    super type

  ###*
    @type {function(new:este.app.View)}
  ###
  viewClass: ->

  ###*
    @type {Object}
  ###
  params: null