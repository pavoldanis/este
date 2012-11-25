###*
  @fileoverview Local storage for este.Model's via HTML5 or IE user data.

  todo:
    check goog.storage.mechanism.ErrorCode.QUOTA_EXCEEDED
    versions
    change scripts
###
goog.provide 'este.storage.Local'

goog.require 'este.json'
goog.require 'este.result'
goog.require 'este.storage.Base'
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
  load: (model) ->
    id = model.getId()
    models = @loadModels model.url
    return este.result.fail() if !models
    json = models[id]
    return este.result.fail() if !json
    model.set json
    este.result.ok id

  ###*
    @inheritDoc
  ###
  save: (model) ->
    id = @ensureModelId model
    serializedModels = @mechanism.get model.url
    models = if serializedModels then este.json.parse serializedModels else {}
    models[id] = model.toJson true
    @saveModels models, model.url
    este.result.ok id

  ###*
    @inheritDoc
  ###
  delete: (model) ->
    id = model.getId()
    if id
      models = @loadModels model.url
      if models && models[id]
        delete models[id]
        @saveModels models, model.url
        return este.result.ok id
    este.result.fail()

  ###*
    @inheritDoc
  ###
  query: (collection, params) ->
    models = @loadModels collection.getUrl()
    array = (model for id, model of models)
    collection.add array
    este.result.ok params

  ###*
    @param {este.Model} model
    @return {string} id
    @protected
  ###
  ensureModelId: (model) ->
    id = model.getId()
    return id if id?
    id = @idFactory()
    model.setId id
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