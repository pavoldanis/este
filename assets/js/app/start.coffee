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

  ###
    This is example of goog.DEBUG, a constant overidable. true for dev, false
    for production. Closure compiler will strip monitor code for production.
  ###
  if goog.DEBUG
    este.dev.Monitor.create()

  ###
    This is example how to use templates with localizable strings via msg tag.
  ###
  html = app.templates.callToAction 'action': 'click'

  ###
    This is example how to create element.
  ###
  box = goog.dom.createDom 'div',
    style: 'width: 250px; height: 80px; background-color: #ff8c55; padding: 1em'
    innerHTML: html
  document.body.appendChild box

  ###*
    This is example how to define localizable strings.
    @desc Text shown in alert after click.
  ###
  app.MSG_THANKYOU = goog.getMsg 'Thank you!'

  ###
    This is example of event registration in Google Closure.
  ###
  goog.events.listen box, 'click', ->
    alert app.MSG_THANKYOU

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start