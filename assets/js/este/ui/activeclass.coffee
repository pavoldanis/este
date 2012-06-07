goog.provide 'este.ui.ActiveClass'

goog.require 'goog.dom.classes'

###*
  @param {Element} element
  @param {Array.<string>} classNames
  @constructor
###
este.ui.ActiveClass = (@element, @classNames) ->

goog.scope ->
  `var _ = este.ui.ActiveClass`

  ###*
    @type {Element}
    @protected
  ###
  _::element

  ###*
    @type {Array.<string>}
    @protected
  ###
  _::classNames

  ###*
    @param {string} className
  ###
  _::set = (className) ->
    goog.dom.classes.addRemove @element, @classNames, className

  return


