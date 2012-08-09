###*
  @fileoverview Experimental MVC stuff.
###

goog.provide 'estemvclab.start'

goog.require 'este.App'
goog.require 'estemvclab.about.View'
goog.require 'estemvclab.contact.View'
# goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
estemvclab.start = (data) ->

  # if goog.DEBUG
  #   este.dev.Monitor.create()

  # todo: DI containerize factories
  #   myApp = este.estemvclab.create [
  #     estemvclab.about.View
  #     estemvclab.contact.View
  #   ]
  #   myestemvclab.start()

  aboutView = new estemvclab.about.View
  contactView = new estemvclab.contact.View

  aboutView.contactView = contactView
  contactView.aboutView = aboutView

  appEl = document.getElementById 'app'
  myApp = este.app.create appEl
  myApp.addViews [
    aboutView
    contactView
  ]
  myApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'estemvclab.start', estemvclab.start

