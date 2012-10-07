###*
  @fileoverview Collection for plain jsons or models. Fires add, remove, change
  events. Event bubbling supported via setParentEventTarget.

  Example
    foos = new Collection [
      id: 1, foo: 'bla bla'
      id: 2, foo: '... bla?'
    ]
    foos.sort
      by: (item) -> item.id
      compare: goog.array.defaultCompare
      reversed: false
    filtered = foos.filter 'foo': 'bla bla'

  Note
    use model-less collections for max performance (10000+ items)

  todo
    consider .defer -> method
###

goog.provide 'este.Collection'

goog.require 'goog.array'
goog.require 'goog.asserts'
goog.require 'goog.events.EventTarget'

class este.Collection extends goog.events.EventTarget

  ###*
    @param {Array.<Object>=} array
    @param {function(new:este.Model)=} model
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (array, @model = @model) ->
    super()
    @array = []
    @fromJson array if array
    return

  ###*
    @enum {string}
  ###
  @EventType:
    ADD: 'add'
    REMOVE: 'remove'
    CHANGE: 'change'

  ###*
    @type {Array.<Object>}
    @protected
  ###
  array: null

  ###*
    @type {function(new:este.Model, Object=, Function=)|null}
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
    @param {Array.<Object>|Object} array
  ###
  add: (array) ->
    array = [array] if !goog.isArray array
    added = []
    for item in array
      if @model && !(item instanceof @model)
        item = new @model item
      if item instanceof goog.events.EventTarget
        item.setParentEventTarget @
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
    @return {Array.<Object>}
  ###
  toArray: ->
    @array

  ###*
    Serialize into JSON.
    @param {boolean=} noMetas If true, metas and clientId are omitted. Works
    only for models.
    @return {Array.<Object>}
  ###
  toJson: (noMetas) ->
    if @model
      item.toJson noMetas for item in @array
    else
      @array.slice 0

  ###*
    Deserialize from JSON.
    @param {Array.<Object>} array
  ###
  fromJson: (array) ->
    @add array

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
      itemId = if @model then item.get('id') else item['id']
      return item if itemId == id
    return

  ###*
    todo: test
    Find item by Id
    @param {*} id
    @return {*}
  ###
  findByClientId: (id) ->
    for item in @array
      itemId = if @model then item.get('clientId') else item['clientId']
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
    @return {function(new:este.Model)|null}
  ###
  getModel: ->
    @model

  ###*
    http://en.wikipedia.org/wiki/Uniform_resource_name
    @return {?string}
  ###
  getUrn: ->
    @model?.prototype?.urn ? null

  ###*
    Filter collection by object or function and returns array of jsons.
    @param {Object|Function} param
    @return {Array}
  ###
  filter: (param) ->
    # remainingCount = (todo for todo in @todos.toJson() when !todo['completed']).length
    array = @toJson()
    switch goog.typeOf param
      when 'function'
        # Enforce tighter type assertion. The compiler can infer the type from
        # the assert and removes it during compilation. http://goo.gl/Bxb5h
        goog.asserts.assertInstanceof param, Function
        item for item in array when param item
      when 'object'
        @filter (item) =>
          for key, value of param
            return false if item[key] != value
          true
      else
        null

  ###*
    todo: add better annotation
    @param {Function} fn
  ###
  each: (fn) ->
    fn item for item in @array
    return

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