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

  show: ->
    super
    document.title = 'show contact'
