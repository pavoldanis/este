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
    @override
  ###
  url: -> super() + 'foo'

  ###*
    @type {este.ui.Resizer}
    @protected
  ###
  resizer: null

  ###*
    @override
  ###
  renderContent: ->
    return if @contentRendered
    @contentRendered = true
    @content.innerHTML = este.demos.app.layout.foo.templates.element()

  ###*
    @override
  ###
  enterDocument: ->
    super()
    @resizer = este.ui.Resizer.create()
    @resizer.targetFilter = (el) =>
      goog.dom.classes.has el, 'este-box'
    @resizer.decorate @content
    return

  ###*
    @override
  ###
  exitDocument: ->
    super()
    @resizer.dispose()
    return