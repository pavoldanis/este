###*
  @fileoverview este.app.Layout.
###
goog.provide 'este.app.Layout'

goog.require 'este.Base'
goog.require 'goog.style'

class este.app.Layout extends este.Base

  ###*
    @param {Element} element
    @constructor
    @extends {este.Base}
  ###
  constructor: (@element) ->
    super

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {este.app.View}
    @protected
  ###
  previousView: null

  ###*
    @param {este.app.View} view
    @param {Object=} params
  ###
  show: (view, params) ->
    if view.getElement().parentNode != @element
      @element.appendChild view.getElement()

    if @previousView
      @previousView.exitDocument()
      goog.style.showElement @previousView.getElement(), false
    @previousView = view

    goog.style.showElement view.getElement(), true
    view.enterDocument()