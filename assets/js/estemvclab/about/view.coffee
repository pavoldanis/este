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
    setTimeout goog.bind(@onLoaded, @), 2000

  ###*
    @protected
  ###
  onLoaded: ->
    document.title = 'show about'
    # todo:
    # getHandler().listen @element, 'click', -> @contactView.show 45
    # todo2: rewrite it to handle specific click automaticaly
    @done()