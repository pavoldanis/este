###*
  @fileoverview Local storage for este.Model's via HTML5 or IE user data.

  todo:
    consider Este <templates>
    check if value was stored
      fire goog.storage.mechanism.ErrorCode.QUOTA_EXCEEDED if not
    scheme
      version
      updaters
###
goog.provide 'este.storage.Local'

goog.require 'este.json'
goog.require 'este.result'
goog.require 'este.storage.Base'
goog.require 'goog.asserts'
goog.require 'goog.object'
goog.require 'goog.storage.mechanism.mechanismfactory'
goog.require 'goog.string'

class este.storage.Local extends este.storage.Base

  ###*
    @param {string} namespace
    @param {goog.storage.mechanism.Mechanism=} mechanism
    @param {function():string=} idFactory
    @constructor
    @extends {este.storage.Base}
  ###
  constructor: (namespace, mechanism, idFactory) ->
    super namespace
    @mechanism = mechanism ?
      goog.storage.mechanism.mechanismfactory.create @namespace
    @idFactory = idFactory ?
      goog.string.getRandomString

  ###*
    @type {goog.storage.mechanism.Mechanism}
    @protected
  ###
  mechanism: null

  ###*
    @type {function():string}
    @protected
  ###
  idFactory: ->

  ###*
    @inheritDoc
  ###
  save: (model) ->
    @checkModelUrn model
    id = @ensureModelId model
    serializedModels = @mechanism.get model.urn
    models = if serializedModels then este.json.parse serializedModels else {}
    models[id] = model.toJson true, true
    @saveModels models, model.urn
    este.result.ok id

  ###*
    @inheritDoc
  ###
  load: (model) ->
    @checkModelUrn model
    id = @checkModelId model
    models = @loadModels model.urn
    return este.result.fail() if !models
    json = models[id]
    return este.result.fail() if !json
    model.set json
    este.result.ok id

  ###*
    @inheritDoc
  ###
  delete: (model) ->
    @checkModelUrn model
    id = @checkModelId model
    if id
      models = @loadModels model.urn
      if models && models[id]
        delete models[id]
        @saveModels models, model.urn
        return este.result.ok id.toString()
    este.result.fail()

  ###*
    @inheritDoc
  ###
  query: (collection, params) ->
    urn = @checkCollectionUrn collection
    models = @loadModels urn
    array = @modelsToArray models
    collection.add array
    este.result.ok params

  ###*
    @param {este.Model} model
    @return {string} id
    @protected
  ###
  ensureModelId: (model) ->
    id = model.get 'id'
    return id.toString() if id?

    id = @idFactory()
    model.set ('id': id), true
    id

  ###*
    @param {Object.<string, Object>} models
    @param {string} urn
    @protected
  ###
  saveModels: (models, urn) ->
    if goog.object.isEmpty models
      @mechanism.remove urn
    else
      serializedJson = este.json.stringify models
      @mechanism.set urn, serializedJson

  ###*
    @param {string} urn
    @return {Object.<string, Object>}
    @protected
  ###
  loadModels: (urn) ->
    serializedJson = @mechanism.get urn
    return null if !serializedJson
    este.json.parse serializedJson

  ###*
    @param {Object.<string, Object>} models
    @return {Array.<Object>}
    @protected
  ###
  modelsToArray: (models) ->
    for id, object of models
      object['id'] = id
      object