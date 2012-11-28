###*
  @fileoverview Sidebar view.
###
goog.provide 'este.demos.app.layout.layouts.sidebar.View'

goog.require 'este.demos.app.layout.layouts.master.View'

class este.demos.app.layout.layouts.sidebar.View extends este.demos.app.layout.layouts.master.View

  ###*
    @constructor
    @extends {este.demos.app.layout.layouts.master.View}
  ###
  constructor: ->
    super()

  ###*
    @type {Element}
    @protected
  ###
  sidebar: null

  ###*
    @type {boolean}
    @protected
  ###
  sidebarRendered: false

  ###*
    @override
  ###
  update: ->
    super()
    @lazyCreateSidebar()
    @renderSidebar()

  ###*
    @protected
  ###
  lazyCreateSidebar: ->
    return if @sidebar
    @sidebar = @dom_.createDom 'div', 'este-sidebar'
    @dom_.insertSiblingAfter @sidebar, @content

  ###*
    @protected
  ###
  renderSidebar: ->
    return if @sidebarRendered
    sidebarRendered = true
    links =
      'About': este.demos.app.layout.about.View
      'Contacts': este.demos.app.layout.contacts.View
    linksHtml = @getLinksHtml links
    @sidebar.innerHTML = linksHtml