###*
  @fileoverview Contacts view.
###
goog.provide 'este.demos.app.layout.contacts.View'

goog.require 'este.demos.app.layout.layouts.sidebar.View'

class este.demos.app.layout.contacts.View extends este.demos.app.layout.layouts.sidebar.View

  ###*
    @constructor
    @extends {este.demos.app.layout.layouts.sidebar.View}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  url: -> super() + 'contacts'

  ###*
    @override
  ###
  renderContent: ->
    @content.innerHTML = 'Contacts content.'