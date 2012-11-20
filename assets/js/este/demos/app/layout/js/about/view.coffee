###*
  @fileoverview About view.
###
goog.provide 'este.demos.app.layout.about.View'

goog.require 'este.demos.app.layout.layouts.sidebar.View'

class este.demos.app.layout.about.View extends este.demos.app.layout.layouts.sidebar.View

  ###*
    @constructor
    @extends {este.demos.app.layout.layouts.sidebar.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: -> super() + 'about'

  ###*
    @inheritDoc
  ###
  renderContent: ->
    @content.innerHTML = 'About content.'