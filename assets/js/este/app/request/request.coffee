###*
  @fileoverview este.app.Request.
###
goog.provide 'este.app.Request'

goog.require 'este.json'

class este.app.Request

  ###*
    @param {este.app.View} view
    @param {Object=} params
    @constructor
  ###
  constructor: (@view, @params = null) ->

  ###*
    @type {este.app.View}
  ###
  view: null

  ###*
    @type {Object}
  ###
  params: null

  ###*
    @param {este.app.Request} request
  ###
  equal: (request) ->
    @view == request.view &&
    este.json.stringify(@params) == este.json.stringify(request.params)
