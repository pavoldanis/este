###*
  @fileoverview este.demos.app.layout.foo.View.
###
goog.provide 'este.demos.app.layout.foo.View'

goog.require 'este.demos.app.layout.foo.templates'
goog.require 'este.demos.app.layout.layouts.master.View'

class este.demos.app.layout.foo.View extends este.demos.app.layout.layouts.master.View

  ###*
    @constructor
    @extends {este.demos.app.layout.layouts.master.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: -> super() + 'foo'

  ###*
    @inheritDoc
  ###
  renderContent: ->
    @content.innerHTML = este.demos.app.layout.foo.templates.element()