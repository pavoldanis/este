###*
  @fileoverview Non destructive innerHTML update. Preserve form fields states,
  prevents images flickering, changes only changed nodes.
  EXPERIMENTAL

  How does it work
    element is clonned (without content)
    clone.innerHTML = html
    element and clone are normalized
    then clone is merged with element, see mergeInternal
    only changed elements are touched

  este.dom.merge el, '<p>new html</p>'

  todo
    tests
    better algorithm for temporally injected nodes via siblings checks
    consider outerHTML optimalization
  @see ../demos/dommerge.html
###

goog.provide 'este.dom.merge'
goog.provide 'este.dom.Merge'

goog.require 'este.dom'
goog.require 'este.json'
goog.require 'goog.array'

###*
  @param {Element} element
  @param {string} html
###
este.dom.merge = (element, html) ->
  merge = new este.dom.Merge element, html
  merge.merge()
  return

class este.dom.Merge

  ###*
    @param {Element} element
    @param {string} html
    @constructor
  ###
  constructor: (@element, @html) ->

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {string}
    @protected
  ###
  html: ''

  ###*
    Merge html into element.
  ###
  merge: ->
    clone = @element.cloneNode false
    clone.innerHTML = @html

    clone.normalize()
    @element.normalize()

    @mergeInternal @element, clone

  ###*
    @param {Element} to
    @param {Element} from
    @protected
  ###
  mergeInternal: (to, from) ->
    toNodes = goog.array.toArray to.childNodes
    fromNodes = goog.array.toArray from.childNodes

    if toNodes.length > fromNodes.length
      howMany = toNodes.length - fromNodes.length
      for node in toNodes.splice fromNodes.length, howMany
        goog.dom.removeNode node

    for fromNode, i in fromNodes
      toNode = toNodes[i]

      if !toNode
        to.appendChild fromNode
        continue

      if toNode.nodeType == 3 && fromNode.nodeType == 3
        toNode.data = fromNode.data
        continue

      if toNode.tagName != fromNode.tagName
        toNode.parentNode.replaceChild fromNode, toNode
        continue

      @mergeAttributes toNode, fromNode
      @mergeInternal toNode, fromNode
    return

  ###*
    @param {Element} toNode
    @param {Element} fromNode
    @protected
  ###
  mergeAttributes: (toNode, fromNode) ->
    # todo: add failing tests
    # props =
    #   'INPUT': 'checked'
    #   'OPTION': 'selected'
    #   'TEXTAREA': 'value'
    # prop = props[fromNode.tagName]
    # value = fromNode[prop] if prop && fromNode[prop]?

    if toNode.hasAttributes()
      for attr in goog.array.toArray toNode.attributes
        continue if fromNode.hasAttribute attr.name
        toNode.removeAttribute attr.name

    if fromNode.hasAttributes()
      for attr in goog.array.toArray fromNode.attributes
        continue if toNode.hasAttribute(attr.name) &&
                    toNode.getAttribute(attr.name) == attr.value
        toNode.setAttribute attr.name, attr.value

    # toNode[prop] = value if value?