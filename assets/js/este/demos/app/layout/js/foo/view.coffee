###*
  @fileoverview Foo view.
###
goog.provide 'este.demos.app.layout.foo.View'

goog.require 'este.demos.app.layout.foo.templates'
goog.require 'este.demos.app.layout.layouts.master.View'
goog.require 'este.ui.Resizer'

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
    @type {este.ui.Resizer}
    @protected
  ###
  resizer: null

  ###*
    @inheritDoc
  ###
  renderContent: ->
    return if @contentRendered
    @contentRendered = true
    @content.innerHTML = este.demos.app.layout.foo.templates.element()

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @resizer = este.ui.Resizer.create()
    @resizer.targetFilter = (el) =>
      goog.dom.classes.has el, 'este-box'
    @resizer.decorate @content
    return

  ###*
    @inheritDoc
  ###
  exitDocument: ->
    super()
    @resizer.dispose()
    return