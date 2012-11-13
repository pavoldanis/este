###*
  @fileoverview Este.js app boilerplate.

  How to create your own app?
    copy assets/css/app.styl into assets/css/yourapp.styl
    copy assets/js/app/*.* into assets/js/yourapp/*.*
    copy app-template.html into yourapp-template.html
    update namespaces and html content form 'app' to 'yourapp'
    done.

###

goog.provide 'app.start'

goog.require 'app.templates'
goog.require 'este.dev.Monitor.create'
goog.require 'goog.dom'
goog.require 'goog.events'

###*
  @param {Object} data JSON from server
###
app.start = (data) ->

  if goog.DEBUG
    este.dev.Monitor.create()

  html = app.templates.callToAction action: 'click'

  box = goog.dom.createDom 'div',
    style: 'width: 250px; height: 80px; background-color: #ff8c55; padding: 1em'
    innerHTML: html
  document.body.appendChild box

  ###*
    @desc Text shown in alert after click.
  ###
  app.MSG_THANKYOU = goog.getMsg 'Thank you!'

  goog.events.listen box, 'click', ->
    alert app.MSG_THANKYOU

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start