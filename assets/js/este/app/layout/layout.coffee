###*
  @fileoverview Layout manager for este.app.View's. Views are rendered lazily,
  enter/exitDocument are called when view is shown/hidden.
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
    if @previousView
      @previousView.exitDocument()
      # element is hidden instead of removed from dom, because
      # dom removing would reset some fields states
      goog.style.showElement @previousView.getElement(), false
    @previousView = view

    # not rendered yet
    if !view.getElement()
      view.render @element
      return

    view.enterDocument()
    goog.style.showElement view.getElement(), true