###*
  @fileoverview estemvclab.contact.View.
###
goog.provide 'estemvclab.contact.View'

goog.require 'este.View'

class estemvclab.contact.View extends este.View

  ###*
    @constructor
    @extends {este.View}
  ###
  constructor: ->
    super

  ###*
    @type {estemvclab.about.View}
  ###
  aboutView: null

  ###*
    @param {number} timeout
  ###
  show: (timeout) ->
    # @
    setTimeout goog.bind(@onLoaded, @, timeout), 2000

  ###*
    @param {number} count
    @protected
  ###
  onLoaded: (count) ->
    document.title = 'show contact' + count
    @done()