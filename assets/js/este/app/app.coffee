###*
  @fileoverview App holds views and its states.
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
    todo: add removeViews and tests for both methods
    @param {Array.<este.View>} views
  ###
  addViews: (views) ->
    for view in views
      view.setParentEventTarget @
      @views.push view
    return

  ###*
    @param {boolean=} silent
  ###
  start: (silent) ->
    @registerListeners()
    # first or matched
    @views[0].show()

  ###*
    @protected
  ###
  registerListeners: ->
    @on @, 'done', @onDone

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onDone: (e) ->
    # todo: use map of active views? not yet
    @currentView = e.target

###*
  @param {Element=} element
  @return {este.App}
###
este.app.create = (element) ->
  new este.App