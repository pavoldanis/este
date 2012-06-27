###*
  @fileoverview Demo of listing view.
###
goog.provide 'app.listing.View'

goog.require 'goog.ui.Component'
goog.require 'app.listing.templates'

###*
  @param {app.listing.Model} model
  @constructor
  @extends {goog.ui.Component}
###
app.listing.View = (@model) ->
  goog.base @
  return

goog.inherits app.listing.View, goog.ui.Component

goog.scope ->
  `var _ = app.listing.View`

  ###*
    @type {app.listing.Model}
  ###
  _::model

  ###*
    @inheritDoc
  ###
  _::createDom = ->
    element = @dom_.createDom 'h1', 'example'
    element.innerHTML = app.listing.templates.list
      items: @model.getItems()
    @setElementInternal element
    return

  ###*
    @inheritDoc
  ###
  _::decorateInternal = (element) ->
    goog.base @, 'decorateInternal', element
    element.style.border = 'solid 1px red'
    return

  ###*
    @inheritDoc
  ###
  _::enterDocument = ->
    goog.base @, 'enterDocument'
    @getHandler().
      listen(@getElement(), 'click', @onClick)
    return

  _::onClick = (e) ->
    @dispatchEvent 'componentclick'

  return








