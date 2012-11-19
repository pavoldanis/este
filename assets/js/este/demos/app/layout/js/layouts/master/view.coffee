###*
  @fileoverview Master view. Bla, Foo, Index views inherit it.
###
goog.provide 'este.demos.app.layout.layouts.master.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.layout.layouts.master.templates'

class este.demos.app.layout.layouts.master.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: -> '/'

  ###*
    @type {Element}
    @protected
  ###
  content: null

  ###*
    @type {boolean}
    @private
  ###
  elementRendered_: false

  ###*
    @inheritDoc
  ###
  update: ->
    @renderElement()
    @content = @getElementByClass 'este-content'
    @renderContent()
    return

  ###*
    @protected
  ###
  renderElement: ->
    return if @elementRendered_
    @elementRendered_ = true
    html = este.demos.app.layout.layouts.master.templates.element
      links: @getLinks()
    @getElement().innerHTML = html

  ###*
    Renders default content. This method should be overridden.
    @protected
  ###
  renderContent: ->
    html = este.demos.app.layout.layouts.master.templates.content()
    este.dom.merge @content, html

  ###*
    todo: add selected.
    @return {Object.<string, string>}
    @protected
  ###
  getLinks: ->
    links = {}
    # can be localized
    links['Bla'] = @getUrl este.demos.app.layout.bla.View
    links['Foo'] = @getUrl este.demos.app.layout.foo.View
    links