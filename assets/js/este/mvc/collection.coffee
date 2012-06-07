###*
  @fileoverview Collection.
  
  todo
    find, sort, filter
###

goog.provide 'este.mvc.Collection'

goog.require 'goog.array'
goog.require 'goog.events.EventTarget'

###*
  @param {Array=} opt_array
  @param {Function=} model
  @constructor
  @extends {goog.events.EventTarget}
###
este.mvc.Collection = (opt_array, @model = null) ->
  goog.base @
  @array = []
  @addMany opt_array if opt_array
  return

goog.inherits este.mvc.Collection, goog.events.EventTarget
  
goog.scope ->
  `var _ = este.mvc.Collection`

  ###*
    @enum {string}
  ###
  _.EventType =
    ADD: 'add'
    REMOVE: 'remove'
    CHANGE: 'change'

  ###*
    @type {Array}
    @protected
  ###
  _::array

  ###*
    @type {Function}
    @protected
  ###
  _::model

  ###*
    @param {*} object Object to add.
  ###
  _::add = (object) ->
    @addMany [object]
    return

  ###*
    @param {Array} array Objects to add.
  ###
  _::addMany = (array) ->
    added = []
    for item in array
      item = if @model then new @model item else item
      added.push item
      item.setParentEventTarget @ if item instanceof goog.events.EventTarget
    @array.push.apply @array, added
    @dispatchEvent
      type: _.EventType.ADD
      added: added
    @dispatchChangeEvent added

  ###*
    @param {*} object Object to remove.
    @return {boolean} True if an element was removed.
  ###
  _::remove = (object) ->
    @removeMany [object]

  ###*
    @param {Array} array Objects to remove.
    @return {boolean} True if any element was removed.
  ###
  _::removeMany = (array) ->
    removed = []
    for item in array
      removed.push item if goog.array.remove @array, item
      item.setParentEventTarget null if item instanceof goog.events.EventTarget
    return false if !removed.length
    @dispatchEvent
      type: _.EventType.REMOVE
      removed: removed
    @dispatchChangeEvent removed
    true

  ###*
    @param {Function} callback
  ###
  _::removeIf = (callback) ->
    toRemove = goog.array.filter @array, callback
    @removeMany toRemove

  _::dispatchChangeEvent = (items) ->
    @dispatchEvent
      type: _.EventType.CHANGE
      items: items

  ###*
    @param {*} object The object for which to test.
    @return {boolean} true if obj is present.
  ###
  _::contains = (object) ->
    goog.array.contains @array, object

  ###*
    @param {number} index
    @return {*}
  ###
  _::at = (index) ->
    @array[index]

  ###*
    @return {number}
  ###
  _::getLength = ->
    @array.length

  ###*
    Serialize into JSON.
    @return {Array}
  ###
  _::toJson = ->
    return @array.slice 0 if !@model
    item.toJson() for item in @array

  ###*
    Clear collection.
  ###
  _::clear = ->
    @removeMany @array.slice 0   

  return










