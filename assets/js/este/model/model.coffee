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

  @see ../demos/model.html
###

goog.provide 'este.Model'
goog.provide 'este.Model.EventType'
goog.provide 'este.Model.Event'

goog.require 'este.json'
goog.require 'este.model.getters'
goog.require 'este.model.setters'
goog.require 'este.model.validators'
goog.require 'goog.asserts'
goog.require 'goog.events.Event'
goog.require 'goog.events.EventTarget'
goog.require 'goog.object'
goog.require 'goog.ui.IdGenerator'

class este.Model extends goog.events.EventTarget

  ###*
    @param {Object=} json
    @param {function(): string=} idGenerator
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (json, idGenerator) ->
    super()
    @attributes = {}
    @schema ?= {}
    @set @defaults if @defaults
    @set json if json
    @ensureClientId idGenerator

  ###*
    @enum {string}
  ###
  @EventType:
    # dispatched on model change
    CHANGE: 'change'
    # dispatched on collection change
    ADD: 'add'
    REMOVE: 'remove'
    SORT: 'sort'
    # dispatched always on any change
    UPDATE: 'update'

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
    # todo: ...
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
    Serialize model, childs included.
    @param {boolean=} noMetas If true, metas and clientId are omitted.
    @param {boolean=} noId If true, id is ommited (used in este.storage.*).
    @return {Object}
  ###
  toJson: (noMetas, noId) ->
    json = {}
    for key, value of @attributes
      origKey = key.substring 1
      continue if noMetas && origKey == 'clientId'
      continue if noId && origKey == 'id'
      attr = @get origKey
      if attr.toJson
        json[origKey] = attr.toJson()
      else
        json[origKey] = attr

    if !noMetas
      for key, value of @schema
        meta = value?['meta']
        continue if !meta
        json[key] = meta @

    json

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
    @protected
  ###
  setInternal: (json) ->
    for key, value of json
      $key = @getKey key
      currentValue = @attributes[$key]
      if key == 'id' && currentValue?
        goog.asserts.fail 'Model id is immutable'
      if key == 'clientId' && currentValue?
        goog.asserts.fail 'Model clientId is immutable'
      @attributes[$key] = value
      continue if !(value instanceof goog.events.EventTarget)
      value.setParentEventTarget @
    return

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
    changeEvent = new este.Model.Event Model.EventType.CHANGE, @
    changeEvent.model = @
    changeEvent.changed = changed
    return false if !@dispatchEvent changeEvent

    updateEvent = new este.Model.Event Model.EventType.UPDATE, @
    updateEvent.origin = changeEvent
    @dispatchEvent updateEvent

  ###*
    @param {function(): string=} idGenerator
    @protected
  ###
  ensureClientId: (idGenerator) ->
    return if @get 'clientId'
    @set 'clientId', if idGenerator
      idGenerator()
    else
      goog.ui.IdGenerator.getInstance().getNextUniqueId()

###*
  @fileoverview este.Model.Event.
###
class este.Model.Event extends goog.events.Event

  ###*
    @param {string} type Event Type.
    @param {goog.events.EventTarget} target
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (type, target) ->
    super type, target

  ###*
    @type {este.Model}
  ###
  model: null

  ###*
    Changed model attributes.
    @type {Object}
  ###
  changed: null

  ###*
    Added models.
    @type {Array.<este.Model>}
  ###
  added: null

  ###*
    Removed models.
    @type {Array.<este.Model>}
  ###
  removed: null

  ###*
    @type {este.Model.Event}
  ###
  origin: null