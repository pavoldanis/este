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
    @type {boolean}
    @protected
  ###
  contentRendered: false

  ###*
    @inheritDoc
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
    links =
      'Home': este.demos.app.layout.index.View
      'Bla': este.demos.app.layout.bla.View
      'Foo': este.demos.app.layout.foo.View
    linksHtml = @getLinksHtml links
    html = este.demos.app.layout.layouts.master.templates.element
      linksHtml: linksHtml
    @getElement().innerHTML = html

  ###*
    Renders default content. This method should be overridden.
    @protected
  ###
  renderContent: ->
    html = este.demos.app.layout.layouts.master.templates.content()
    este.dom.merge @content, html

  ###*
    @param {Object.<string, function(new:este.app.View)>} links
    @return {string}
    @protected
  ###
  getLinksHtml: (links) ->
    linksArray = for title, view of links
      title: title
      href: @createUrl view
      selected: @ instanceof view
    este.demos.app.layout.layouts.master.templates.links
      links: linksArray