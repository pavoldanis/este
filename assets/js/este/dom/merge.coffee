###*
  @fileoverview DOM Merger. Good for .innerHTML partial updates. innerHTML is
  tricky. Fields can lost focus, images can flicker..., DOM Merger fixes it.
  Just proof of concept now.

  todo
    more inteligent merging, consider when to add, replace, remove element
    for input, textarea.. just update values
    tests, consider unit vs. qunit like within real browser

###
goog.provide 'este.dom.Merge'
goog.provide 'este.dom.merge'

goog.require 'este.dom'
goog.require 'este.json'

###*
  @param {Element} element
  @param {string} html
  @constructor
###
este.dom.Merge = (@element, @html) ->
  return

goog.scope ->
  `var _ = este.dom.Merge`

  ###*
    @param {Element} element
    @param {string} html
  ###
  este.dom.merge = (element, html) ->
    instance = new _ element, html
    instance.merge()
    return

  ###*
    @type {Element}
    @protected
  ###
  _::element

  ###*
    @type {string}
    @protected
  ###
  _::html

  ###*
    innerHTML without innerHTML. DOM manipulations ftw.
  ###
  _::merge = ->
    @element.normalize()
    clone = @createClone()
    @mergeInternal @element, clone
    # @element.innerHTML = @html

  ###*
    @param {Element} to
    @param {Element} from
    @protected
  ###
  _::mergeInternal = (to, from) ->
    toNodes = goog.array.toArray to.childNodes
    fromNodes = goog.array.toArray from.childNodes

    if toNodes.length > fromNodes.length
      howMany = toNodes.length - fromNodes.length
      for node in toNodes.splice fromNodes.length, howMany
        goog.dom.removeNode node

    for fromNode, i in fromNodes
      toNode = toNodes[i]

      if !@nodesAreSameTypeTagAttributes fromNode, toNode
        if toNode?.parentNode
          goog.dom.replaceNode fromNode, toNode
        else
          to.appendChild fromNode
        continue

      if @nodesAreElements fromNode, toNode
        @mergeInternal toNode, fromNode
        continue
      
      if @nodesAreTextNodes fromNode, toNode
        toNode.data = fromNode.data
        continue

    return

  ###*
    @param {Node} fromNode
    @param {Node} toNode
    @return {boolean}
    @protected
  ###
  _::nodesAreSameTypeTagAttributes = (fromNode, toNode) ->
    fromNode? && toNode? &&
    fromNode.nodeType == 1 && toNode.nodeType == 1 &&
    fromNode.tagName == toNode.tagName &&
    @getSerializedAttributes(fromNode) == @getSerializedAttributes(toNode)

  ###*
    @param {Node} node
    @return {string}
    @protected
  ###
  _::getSerializedAttributes = (node) ->
    return '' if !node || !node.attributes || !node.attributes.length
    attributes = ([attr.name, attr.value] for attr in node.attributes)
    este.json.stringify attributes

  ###*
    @param {Node} fromNode
    @param {Node} toNode
    @return {boolean}
    @protected
  ###
  _::nodesAreTextNodes = (fromNode, toNode) ->
    fromNode?.nodeType == 3 && toNode?.nodeType == 3

  ###*
    @param {Node} fromNode
    @param {Node} toNode
    @return {boolean}
    @protected
  ###
  _::nodesAreElements = (fromNode, toNode) ->
    fromNode?.nodeType == 1 && toNode?.nodeType == 1

  ###*
    @return {Element}
    @protected
  ###
  _::createClone = ->
    clone = @element.cloneNode false
    clone.innerHTML = @html
    clone.normalize()
    clone

  return






