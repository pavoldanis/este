###*
  @fileoverview este.App.
  WARNING: This is still highly experimental.
###
goog.provide 'este.App'
goog.provide 'este.app.create'

goog.require 'este.Base'

class este.App extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    super
    @views = []

  ###*
    @type {Array.<este.View>}
    @protected
  ###
  views: null

  ###*
    @param {Array.<este.View>} views
  ###
  addViews: (views) ->
    for view in views
      view.app = @
      @views.push view
    return

  ###*
    @param {boolean=} foo
  ###
  start: (foo) ->
    @views[0].show()

  ###*
    @param {este.View} view
  ###
  show: (view) ->

###*
  @return {este.App}
###
este.app.create = ->
  new este.App