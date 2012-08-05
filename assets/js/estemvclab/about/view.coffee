###*
  @fileoverview estemvclab.about.View.
###
goog.provide 'estemvclab.about.View'

goog.require 'este.View'

class estemvclab.about.View extends este.View

  ###*
    @constructor
    @extends {este.View}
  ###
  constructor: ->
    super

  ###*
    @type {estemvclab.contact.View}
  ###
  contactView: null

  show: ->
    super
    document.title = 'show about'