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
    @override
  ###
  url: -> super() + 'about'

  ###*
    @override
  ###
  renderContent: ->
    @content.innerHTML = 'About content.'