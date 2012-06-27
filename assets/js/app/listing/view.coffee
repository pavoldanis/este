###*
  @fileoverview Demo of listing view.
###
goog.provide 'app.listing.View'

goog.require 'goog.ui.Component'
goog.require 'app.listing.templates'

###*
  @constructor
  @extends {goog.ui.Component}
###
app.listing.View = ->
  goog.base @
  return

goog.inherits app.listing.View, goog.ui.Component

goog.scope ->
  `var _ = app.listing.View`

  ###*
    @inheritDoc
  ###
  _::createDom = ->
    element = @dom_.createDom 'h1', 'example'
    element.innerHTML = app.listing.templates.list
      items: [
        id: 1
        text: 'Ahoj'
        title: 'Ahoj'
      ,
        id: 2
        text: 'Světe'
        title: 'Světe'
      ]
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

  ###*
    @desc Not all selects were selected.
  ###
  _.MSG_PLEASE_CHOOSE = goog.getMsg 'Prosím vyberte: '

  return








