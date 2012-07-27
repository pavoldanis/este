###*
  @fileoverview Collection. Stores JSONs or models. Fires add, remove,
  change events. Supports events bubbling via setParentEventTarget.

  Example
    foos = new Collection [
      id: 1, foo: 'bla bla'
      id: 2, foo: '... bla?'
    ]
    foos.sort
      by: (item) -> item.id
      compare: goog.array.defaultCompare
      reversed: false

  todo
    filter
    docs&examples (see tests now)
###

goog.provide 'este.Collection'

goog.require 'goog.array'
goog.require 'goog.events.EventTarget'

###*
  @param {Array=} array
  @param {Function=} model
  @constructor
  @extends {goog.events.EventTarget}
###
este.Collection = (array, @model = null) ->
  goog.base @
  @array = []
  @addMany array if array
  return

goog.inherits este.Collection, goog.events.EventTarget
  
goog.scope ->
  `var _ = este.Collection`

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
    @type {Function}
    @protected
  ###
  _::sortBy = (item) -> item

  ###*
    todo: check date
    @type {Function}
    @protected
  ###
  _::sortCompare = goog.array.defaultCompare

  ###*
    @type {boolean}
    @protected
  ###
  _::sortReversed = false

  ###*
    @param {...*} var_args
  ###
  _::add = (var_args) ->
    @addMany arguments
    return

  ###*
    @param {goog.array.ArrayLike} array Objects to add.
  ###
  _::addMany = (array) ->
    added = []
    for item in array
      item = new @model item if @model && !(item instanceof @model)
      added.push item
      if item instanceof goog.events.EventTarget
        item.setParentEventTarget @
    @array.push.apply @array, added
    @sortInternal()
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
    @param {goog.array.ArrayLike} array Objects to remove.
    @return {boolean} True if any element was removed.
  ###
  _::removeMany = (array) ->
    removed = []
    for item in array
      removed.push item if goog.array.remove @array, item
      if item instanceof goog.events.EventTarget
        item.setParentEventTarget null
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

  ###*
    todo: consider rename items to changed
    @param {Array} items
    @protected
  ###
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

  ###*
    Find item
    @param {Function} fn
    @return {*}
  ###
  _::find = (fn) ->
    for item in @array
      return item if fn item
    return

  ###*
    Find item by Id
    @param {*} id
    @return {*}
  ###
  _::findById = (id) ->
    for item in @array
      itemId = if @model then item.get('id') else item.id
      return item if itemId == id
    return

  ###*
    @param {{by: Function, compare: Function, reversed: boolean}=} options
  ###
  _::sort = (options) ->
    @sortBy = options.by if options?.by != undefined
    @sortCompare = options.compare if options?.compare != undefined
    @sortReversed = options.reversed if options?.reversed != undefined
    @sortInternal()
    @dispatchChangeEvent null
    return

  ###*
    @protected
  ###
  _::sortInternal = ->
    return if !@sortBy || !@sortCompare
    @array.sort (a, b) =>
      a = @sortBy a
      b = @sortBy b
      @sortCompare a, b
    @array.reverse() if @sortReversed
    return

  return










