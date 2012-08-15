###*
  @fileoverview este.mvc.app.Request.
###

goog.provide 'este.mvc.app.Request'

goog.require 'este.json'

class este.mvc.app.Request

  ###*
    @param {este.mvc.View} view
    @param {Object=} params
    @constructor
  ###
  constructor: (@view, @params = null) ->

  ###*
    @type {este.mvc.View}
  ###
  view: null

  ###*
    @type {Object}
  ###
  params: null

  ###*
    @param {Object=} viewData
  ###
  setViewData: (viewData = {}) ->
    @view.viewData = viewData

  ###*
    @param {Function} onViewFetched
  ###
  fetch: (onViewFetched) ->
    @view.fetch @params, (response) =>
      onViewFetched @, response

  ###*
    @param {este.mvc.app.Request} request
  ###
  equal: (request) ->
    return false if !request
    return false if @view != request.view
    este.json.stringify(@params) == este.json.stringify(request.params)