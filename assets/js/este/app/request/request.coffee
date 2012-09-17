###*
  @fileoverview este.app.Request.
###
goog.provide 'este.app.Request'

goog.require 'este.json'
goog.require 'goog.result.SimpleResult'

class este.app.Request

  ###*
    @param {este.app.View} view
    @param {Object=} params
    @param {boolean=} silent
    @constructor
  ###
  constructor: (@view, @params = null, @silent = false) ->

  ###*
    @type {este.app.View}
  ###
  view: null

  ###*
    @type {Object}
  ###
  params: null

  ###*
    @type {boolean}
  ###
  silent: false

  ###*
    @param {este.app.Request} request
  ###
  equal: (request) ->
    @view == request.view && este.json.equal @params, request.params