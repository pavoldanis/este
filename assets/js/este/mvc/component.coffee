###*
  @fileoverview Component.
###

goog.provide 'este.mvc.Component'

goog.require 'goog.ui.Component'
goog.require 'goog.dom.forms'
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
    object = goog.dom.forms.getFormDataMap(target).toObject()
    # we do not want single item array values
    object = goog.object.map object, (v, k) ->
      return v[0] if goog.isArray(v) && v.length == 1
      v
    @onFormSubmit target, object
    
  ###*
    @protected
  ###
  _::onFormSubmit = (form, object) ->


  return