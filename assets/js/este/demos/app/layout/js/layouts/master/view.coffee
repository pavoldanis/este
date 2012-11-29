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
    @override
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
    @type {boolean}
    @protected
  ###
  contentRendered: false

  ###*
    @override
  ###
  update: ->
    @renderElement()
    @content ?= @getElementByClass 'este-content'
    @renderContent()
    return

  ###*
    Renders whole layout with one content region.
    @protected
  ###
  renderElement: ->
    return if @elementRendered_
    @elementRendered_ = true
    html = este.demos.app.layout.layouts.master.templates.element
      linksHtml: @getLinksHtml()
    @getElement().innerHTML = html

  ###*
    @return {string}
    @protected
  ###
  getLinksHtml: ->
    este.app.renderLinks @, [
      title: 'Home', view: este.demos.app.layout.index.View
    ,
      title: 'Bla', view: este.demos.app.layout.bla.View
    ,
      title: 'Foo', view: este.demos.app.layout.foo.View
    ]

  ###*
    Renders default content. This method should be overridden.
    @protected
  ###
  renderContent: ->
    html = este.demos.app.layout.layouts.master.templates.content()
    este.dom.merge @content, html