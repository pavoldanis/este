###*
  @fileoverview Model with attributes and schema.

  Why not plain JS objects?
    - http://www.devthought.com/2012/01/18/an-object-is-not-a-hash
    - reusable setters, getters, and validators
    - strings are good for uncompiled properties from DOM and server

  tips
    modify complex object: joe.get('items').add 'foo'
    use goog.object.extend to 'inherit' schema

  todo
    - example
###

goog.provide 'este.Model'
goog.provide 'este.Model.EventType'

goog.require 'este.json'
goog.require 'goog.events.EventTarget'
goog.require 'goog.object'
goog.require 'goog.string'

goog.require 'este.model.getters'
goog.require 'este.model.setters'
goog.require 'este.model.validators'

class este.Model extends goog.events.EventTarget

  ###*
    @param {Object=} json
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (json = {}) ->
    super()
    @attributes = {}
    @schema ?= {}
    json['id'] ?= goog.string.getRandomString()
    @setInternal json

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGE: 'change'

  ###*
    Prefix because http://www.devthought.com/2012/01/18/an-object-is-not-a-hash
    @param {string} key
    @return {string}
  ###
  @getKey: (key) ->
    '$' + key

  ###*
    @param {Object|string} object Object of key value pairs or string key.
    @param {*=} opt_value value or nothing.
    @return {Object}
  ###
  @getObject: (object, opt_value) ->
    return object if !goog.isString object
    key = object
    object = {}
    object[key] = opt_value
    object

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
    Returns models attribute.
    @param {string|Array.<string>} key
    @return {*}
  ###
  get: (key) ->
    if typeof key != 'string'
      object = {}
      object[k] = @get k for k in key
      return object
    value = @attributes[Model.getKey(key)]
    meta = @schema[key]?['meta']
    return meta @ if meta
    get = @schema[key]?.get
    return get value if get
    value

  ###*
    set 'prop', value or set 'prop': 'value'.
    Invalid values are ignored.
    Dispatch change event with changed property, if any.
    Returns errors object.
    @param {Object|string} object Object of key value pairs or string key.
    @param {*=} opt_value value or nothing.
    @return {Object} errors object, ex. name: required: true if error
  ###
  set: (object, opt_value) ->
    object = Model.getObject object, opt_value
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
    @param {Object} object
    @protected
  ###
  setInternal: (object) ->
    for key, value of object
      @attributes[Model.getKey(key)] = value
      continue if !(value instanceof goog.events.EventTarget)
      value.setParentEventTarget @
    return

  ###*
    todo: optimize value changed comparison
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

  ###*
    @param {string} key
    @return {boolean}
  ###
  has: (key) ->
    Model.getKey(key) of @attributes

  ###*
    @param {string} key
    @return {boolean} true if removed
  ###
  remove: (key) ->
    _key = Model.getKey key
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
    @param {boolean=} withoutMetas
    @return {Object}
  ###
  toJson: (withoutMetas = false) ->
    object = {}
    for key, value of @attributes
      origKey = key.substring 1
      newValue = @get origKey
      object[origKey] = newValue
    return object if withoutMetas
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





