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

class este.Collection extends goog.events.EventTarget

  ###*
    @param {Array=} array
    @param {Function=} model
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (array, model) ->
    super()
    @model = model if model
    @array = []
    @add array if array
    return

  ###*
    @enum {string}
  ###
  @EventType:
    ADD: 'add'
    REMOVE: 'remove'
    CHANGE: 'change'

  ###*
    @type {Array}
    @protected
  ###
  array: null

  ###*
    @type {Function}
    @protected
  ###
  model: null

  ###*
    @type {Function}
    @protected
  ###
  sortBy: (item) ->
    item

  ###*
    todo: check date
    @type {Function}
    @protected
  ###
  sortCompare: goog.array.defaultCompare

  ###*
    @type {boolean}
    @protected
  ###
  sortReversed: false

  ###*
    @param {Array|Object} array
  ###
  add: (array) ->
    array = [array] if !goog.isArray array
    added = []
    for item in array
      item = new @model item if @model && !(item instanceof @model)
      item.setParentEventTarget @ if item instanceof goog.events.EventTarget
      added.push item
    @array.push.apply @array, added
    @sortInternal()
    @dispatchAddEvent added
    @dispatchChangeEvent added
    return

  ###*
    @param {Array|Object} array
    @return {boolean} True if an element was removed.
  ###
  remove: (array) ->
    array = [array] if !goog.isArray array
    removed = []
    for item in array
      item.setParentEventTarget null if item instanceof goog.events.EventTarget
      removed.push item if goog.array.remove @array, item
    return false if !removed.length
    @dispatchRemoveEvent removed
    @dispatchChangeEvent removed
    true

  ###*
    @param {Function} callback
  ###
  removeIf: (callback) ->
    toRemove = goog.array.filter @array, callback
    @remove toRemove

  ###*
    @param {Array} added
    @protected
  ###
  dispatchAddEvent: (added) ->
    @dispatchEvent
      type: Collection.EventType.ADD
      added: added

  ###*
    @param {Array} removed
    @protected
  ###
  dispatchRemoveEvent: (removed) ->
    @dispatchEvent
      type: Collection.EventType.REMOVE
      removed: removed

  ###*
    @param {Array} changed
    @protected
  ###
  dispatchChangeEvent: (changed) ->
    @dispatchEvent
      type: Collection.EventType.CHANGE
      changed: changed

  ###*
    @param {*} object The object for which to test.
    @return {boolean} true if obj is present.
  ###
  contains: (object) ->
    goog.array.contains @array, object

  ###*
    @param {number} index
    @return {*}
  ###
  at: (index) ->
    @array[index]

  ###*
    @return {number}
  ###
  getLength: ->
    @array.length

  ###*
    Serialize into JSON.
    @return {Array}
  ###
  toJson: ->
    return @array.slice 0 if !@model
    item.toJson() for item in @array

  ###*
    Clear collection.
  ###
  clear: ->
    @remove @array.slice 0

  ###*
    Find item
    @param {Function} fn
    @return {*}
  ###
  find: (fn) ->
    for item in @array
      return item if fn item
    return

  ###*
    Find item by Id
    @param {*} id
    @return {*}
  ###
  findById: (id) ->
    for item in @array
      itemId = if @model then item.get('id') else item.id
      return item if itemId == id
    return

  ###*
    @param {{by: Function, compare: Function, reversed: boolean}=} options
  ###
  sort: (options) ->
    @sortBy = options.by if options?.by != undefined
    @sortCompare = options.compare if options?.compare != undefined
    @sortReversed = options.reversed if options?.reversed != undefined
    @sortInternal()
    @dispatchChangeEvent null
    return

  ###*
    @protected
  ###
  sortInternal: ->
    return if !@sortBy || !@sortCompare
    @array.sort (a, b) =>
      a = @sortBy a
      b = @sortBy b
      @sortCompare a, b
    @array.reverse() if @sortReversed
    return