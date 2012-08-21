###*
  @fileoverview Model with attributes and schema.

  Features
    setters, getters, validators
    model's events bubble up

  Why not plain objects?
    - http://www.devthought.com/2012/01/18/an-object-is-not-a-hash
    - reusable setters, getters, and validators
    - strings are fine for uncompiled attributes from DOM or storage etc.

  Notes
    - use model.get('clientId') for rendering
    - to modify complex attribute: joe.get('items').add 'foo'
    - to 'inherit' schema: use goog.object.extend
###

goog.provide 'este.Model'
goog.provide 'este.Model.EventType'

goog.require 'este.json'
goog.require 'goog.events.EventTarget'
goog.require 'goog.object'
goog.require 'goog.string'
goog.require 'goog.ui.IdGenerator'

goog.require 'este.model.getters'
goog.require 'este.model.setters'
goog.require 'este.model.validators'

class este.Model extends goog.events.EventTarget

  ###*
    @param {Object=} json
    @param {Function=} idGenerator
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (json, idGenerator) ->
    super()
    @attributes = {}
    @attributes[@getKey 'clientId'] = if idGenerator
      idGenerator()
    else
      goog.ui.IdGenerator.getInstance().getNextUniqueId()
    @schema ?= {}
    @setInternal json if json

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGE: 'change'

  ###*
    @type {Object}
    @protected
  ###
  attributes: null

  ###*
    @type {Object}
    @protected
  ###
  schema: null

  ###*
    Set model attribute(s).
    model.set 'foo', 1
    model set 'foo': 1, 'bla': 2
    Invalid values are ignored.
    Dispatch change event with changed property, if any.
    Returns errors.
    @param {Object|string} object Object of key value pairs or string key.
    @param {*=} opt_value value or nothing.
    @return {Object} errors object, ex. name: required: true if error
  ###
  set: (object, opt_value) ->
    if typeof object == 'string'
      _object = {}
      _object[object] = opt_value
      object = _object

    changes = @getChanges object
    return null if !changes

    errors = @getErrors changes
    if errors
      changes = goog.object.filter changes, (value, key) -> !errors[key]

    if !goog.object.isEmpty changes
      @setInternal changes
      @dispatchChangeEvent changes

    errors

  ###*
    Returns model attribute(s).
    @param {string|Array.<string>} key
    @return {*|Object.<string, *>}
  ###
  get: (key) ->
    if typeof key != 'string'
      object = {}
      object[k] = @get k for k in key
      return object

    meta = @schema[key]?['meta']
    return meta @ if meta

    value = @attributes[@getKey key]
    get = @schema[key]?.get
    return get value if get

    value

  ###*
    @param {string} key
    @return {boolean}
  ###
  has: (key) ->
    @getKey(key) of @attributes

  ###*
    @param {string} key
    @return {boolean} true if removed
  ###
  remove: (key) ->
    _key = @getKey key
    return false if !(_key of @attributes)
    value = @attributes[_key]
    value.setParentEventTarget null if value instanceof goog.events.EventTarget
    delete @attributes[_key]
    changed = {}
    changed[key] = value
    @dispatchChangeEvent changed
    true

  ###*
    Returns shallow copy.
    @param {boolean=} noMetas If true, no metas nor clientId.
    @return {Object}
  ###
  toJson: (noMetas) ->
    object = {}
    for key, value of @attributes
      origKey = key.substring 1
      continue if noMetas && origKey == 'clientId'
      newValue = @get origKey
      object[origKey] = newValue
    return object if noMetas
    for key, value of @schema
      meta = value?['meta']
      continue if !meta
      object[key] = meta @
    object

  ###*
    @return {Object} errors object, ex. name: required: true if error
  ###
  validate: ->
    keys = (key for key, value of @schema when value?['validators'])
    values = @get keys
    `values = /** @type {Object} */ (values)`
    @getErrors values

  ###*
    Prefix because http://www.devthought.com/2012/01/18/an-object-is-not-a-hash
    @param {string} key
    @return {string}
  ###
  getKey: (key) ->
    '$' + key

  ###*
    @param {Object} object
    @protected
  ###
  setInternal: (object) ->
    for key, value of object
      @attributes[@getKey key] = value
      continue if !(value instanceof goog.events.EventTarget)
      value.setParentEventTarget @
    return

  ###*
    todo: optimize comparison
    @param {Object} object
    @return {Object}
    @protected
  ###
  getChanges: (object) ->
    changes = null
    for key, value of object
      set = @schema[key]?.set
      value = set value if set
      continue if este.json.stringify(value) == este.json.stringify @get key
      changes ?= {}
      changes[key] = value
    changes

  ###*
    @param {Object} object key is attr, value is its value
    @return {Object}
    @protected
  ###
  getErrors: (object) ->
    errors = null
    for key, value of object
      validators = @schema[key]?['validators']
      continue if !validators
      for name, validator of validators
        continue if validator value
        errors ?= {}
        errors[key] ?= {}
        errors[key][name] = true
    errors

  ###*
    @param {Object} changed
    @protected
  ###
  dispatchChangeEvent: (changed) ->
    @dispatchEvent
      type: Model.EventType.CHANGE
      changed: changed