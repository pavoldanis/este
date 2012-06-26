###*
  @fileoverview Component.
###

goog.provide 'este.mvc.Component'

goog.require 'goog.ui.Component'
goog.require 'este.dom'
goog.require 'goog.object'

###*
  @param {goog.dom.DomHelper=} opt_domHelper Optional DOM helper.
  @constructor
  @extends {goog.ui.Component}
###
este.mvc.Component = (opt_domHelper) ->
  goog.base @, opt_domHelper
  return

goog.inherits este.mvc.Component, goog.ui.Component
  
goog.scope ->
  `var _ = este.mvc.Component`

  ###*
    @override
  ###
  _::enterDocument = ->
    goog.base @, 'enterDocument'
    # todo: (re)create and use form submit bubbling handler
    for form in @getElement().getElementsByTagName 'form'
      @getHandler().listen form, 'submit', @onFormSubmit_
    return

  ###*
    @private
  ###
  _::onFormSubmit_ = (e) ->
    e.preventDefault()
    target = e.target
    object = este.dom.serializeForm target
    @onFormSubmit target, object
    
  ###*
    @protected
  ###
  _::onFormSubmit = (form, object) ->


  return