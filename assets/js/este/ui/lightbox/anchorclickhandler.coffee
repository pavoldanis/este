###
  @fileoverview este.ui.lightbox.AnchorClickHandler.
###

goog.provide 'este.ui.lightbox.AnchorClickHandler'

goog.require 'goog.ui.Component'

class este.ui.lightbox.AnchorClickHandler extends goog.ui.Component

  ###*
    @constructor
    @extends {goog.ui.Component}
  ###
  constructor: ->

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @getHandler().
      listen(@getElement(), 'click', @onClick)
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onClick: (e) ->
    anchor = @getLightboxAnchorAncestor e.target
    return if !anchor
    e.preventDefault()
    @dispatchClickEvent anchor

  ###*
    @param {Node} node
    @protected
  ###
  getLightboxAnchorAncestor: (node) ->
    @dom_.getAncestor node, (node) ->
      node.tagName == 'A' && !node.rel.indexOf 'lightbox'
    , true

  ###*
    @param {Element} anchor
    @protected
  ###
  dispatchClickEvent: (anchor) ->
    anchors = @getAnchorsWithSameRelAttribute anchor.rel
    @dispatchEvent
      type: 'click'
      currentAnchor: anchor
      anchors: anchors

  ###*
    @param {string} rel
    @protected
  ###
  getAnchorsWithSameRelAttribute: (rel) ->
    @getElement().querySelectorAll "a[rel='#{rel}']"