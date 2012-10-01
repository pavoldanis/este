###*
  @fileoverview Model with attributes and schema.

  Features
    setters, getters, validators
    model's change event with event bubbling
    JSON serialization

  Why not plain objects?
    - http://www.devthought.com/2012/01/18/an-object-is-not-a-hash
    - strings are better for uncompiled attributes from DOM or storage etc.

  clientId
    clientId is temporary session id. It's erased when you close your browser.
    It's used for HTML rendering, it starts with ':'.
    For local storage persistence is used este.storage.Local unique-enough ID.

  Notes
    - to modify complex attribute: joe.get('items').add 'foo'

  todo
    consider to make urn class static
    consider imperative schema definition (methods call instead of {} literal)
      will be self inherited automatically
###

goog.provide 'este.Model'
goog.provide 'este.Model.EventType'

goog.require 'este.json'
goog.require 'este.model.getters'
goog.require 'este.model.setters'
goog.require 'este.model.validators'
goog.require 'goog.asserts'
goog.require 'goog.events.EventTarget'
goog.require 'goog.object'
goog.require 'goog.string'
goog.require 'goog.ui.IdGenerator'

class este.Model extends goog.events.EventTarget

  ###*
    @param {Object=} json
    @param {function(): string=} idGenerator
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (json = {}, @idGenerator = null) ->
    super()
    @attributes = {}
    @schema ?= {}
    @setId json
    @setClientId json, idGenerator
    @fromJson @defaults if @defaults
    @fromJson json, true

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGE: 'change'

  ###*
    http://en.wikipedia.org/wiki/Uniform_resource_name
    It's used by este.storage.Local and este.storage.Local.
    @type {string}
  ###
  urn: 'model'

  ###*
    @type {Object}
    @protected
  ###
  attributes: null

  ###*
    @type {Object}
    @protected
  ###
  defaults: null

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
    @param {Object|string} json Object of key value pairs or string key.
    @param {*=} value value or nothing.
    @return {Object} errors object, ex. name: required: true if error
  ###
  set: (json, value) ->
    return null if !json

    if typeof json == 'string'
      _json = {}
      _json[json] = value
      json = _json

    changes = @getChanges json
    return null if !changes

    errors = @getErrors changes
    if errors
      changes = goog.object.filter changes, (value, key) -> !errors[key]

    if !goog.object.isEmpty changes
      @fromJson changes
      @dispatchChangeEvent changes

    errors

  ###*
    Returns model attribute(s).
    @param {string|Array.<string>} key
    @return {*|Object.<string, *>}
  ###
  get: (key) ->
    if typeof key != 'string'
      json = {}
      json[k] = @get k for k in key
      return json

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
    return true if @getKey(key) of @attributes
    return true if @schema[key]?['meta']
    false

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
    Returns shallow copy. It's used for serialization.
    @param {boolean=} noMetas If true, no metas nor clientId.
    @param {boolean=} noId
    @return {Object}
  ###
  toJson: (noMetas, noId) ->
    json = {}
    for key, value of @attributes
      origKey = key.substring 1
      continue if noMetas && origKey == 'clientId'
      continue if noId && origKey == 'id'
      newValue = @get origKey
      json[origKey] = newValue

    if !noMetas
      for key, value of @schema
        meta = value?['meta']
        continue if !meta
        json[key] = meta @

    json

  ###*
    Accept shallow copy. It's used for deserialization.
    @param {Object} json
    @param {boolean=} forceIds for
  ###
  fromJson: (json, forceIds) ->
    if !forceIds
      goog.asserts.assert !json['id'], 'Model id is immutable'
      goog.asserts.assert !json['clientId'], 'Model clientId is immutable'

    for key, value of json
      @attributes[@getKey key] = value
      continue if !(value instanceof goog.events.EventTarget)
      value.setParentEventTarget @
    return

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
    @param {Object} json
    @private
  ###
  setId: (json) ->
    @attributes[@getKey 'id'] = json['id'] if json['id']?

  ###*
    @param {Object} json
    @param {function(): string=} idGenerator
    @private
  ###
  setClientId: (json, idGenerator) ->
    clientIdKey = @getKey 'clientId'
    @attributes[clientIdKey] = if json['id']?
      json['id']
    else if @idGenerator
      @idGenerator()
    else
      goog.ui.IdGenerator.getInstance().getNextUniqueId()

  ###*
    todo: optimize comparison
    @param {Object} json
    @return {Object}
    @protected
  ###
  getChanges: (json) ->
    changes = null
    for key, value of json
      set = @schema[key]?.set
      value = set value if set
      continue if este.json.equal value, @get key
      changes ?= {}
      changes[key] = value
    changes

  ###*
    @param {Object} json key is attr, value is its value
    @return {Object}
    @protected
  ###
  getErrors: (json) ->
    errors = null
    for key, value of json
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