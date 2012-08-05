###*
  @fileoverview este.View.
  WARNING: This is still highly experimental.
###
goog.provide 'este.View'

goog.require 'este.Base'

class este.View extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    super

  ###*
    @type {este.App}
  ###
  app: null

  ###*
    To be overriden and called via super.
  ###
  show: ->
    @app.show @