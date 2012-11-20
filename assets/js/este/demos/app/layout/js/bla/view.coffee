###*
  @fileoverview Bla view.
###
goog.provide 'este.demos.app.layout.bla.View'

goog.require 'este.demos.app.layout.bla.templates'
goog.require 'este.demos.app.layout.layouts.master.View'

class este.demos.app.layout.bla.View extends este.demos.app.layout.layouts.master.View

  ###*
    @constructor
    @extends {este.demos.app.layout.layouts.master.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: -> super() + 'bla'

  ###*
    @inheritDoc
  ###
  events: ->
    super()
    @on @content,
      'div click': @onDivClick

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onDivClick: (e) ->
    alert '.este-content clicked'

  ###*
    @inheritDoc
  ###
  renderContent: ->
    return if @contentRendered
    @contentRendered = true
    @content.innerHTML = este.demos.app.layout.bla.templates.element()