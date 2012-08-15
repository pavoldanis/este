###*
  @fileoverview Simple layout, only one element is in DOM in time.
###
goog.provide 'este.mvc.Layout'

goog.require 'goog.dom'

class este.mvc.Layout

  ###*
    @param {Element} element
    @constructor
  ###
  constructor: (@element) ->

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {este.mvc.View}
    @protected
  ###
  previousView: null

  ###*
    @param {este.mvc.View} view
    @param {Object=} params
  ###
  setActive: (view, params) ->
    goog.dom.removeChildren @element
    if @previousView
      @previousView.exitDocument()
    view.render()
    @element.appendChild view.element
    view.enterDocument()
    @previousView = view


