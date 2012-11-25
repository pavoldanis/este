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
    models = @loadModels model.getUrl()
    return este.result.fail() if !models
    json = models[id]
    return este.result.fail() if !json
    model.set json
    este.result.ok id

  ###*
    @inheritDoc
  ###
  save: (model) ->
    @ensureModelId model
    id = model.getId()
    serializedModels = @mechanism.get model.getUrl()
    models = if serializedModels then este.json.parse serializedModels else {}
    models[id] = model.toJson true
    @saveModels models, model.getUrl()
    este.result.ok id

  ###*
    @inheritDoc
  ###
  delete: (model) ->
    id = model.getId()
    if id
      models = @loadModels model.getUrl()
      if models && models[id]
        delete models[id]
        @saveModels models, model.getUrl()
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
    @protected
  ###
  ensureModelId: (model) ->
    id = model.getId()
    return if id
    model.setId @idFactory()

  ###*
    @param {Object.<string, Object>} models
    @param {string} url
    @protected
  ###
  saveModels: (models, url) ->
    if goog.object.isEmpty models
      @mechanism.remove url
    else
      serializedJson = este.json.stringify models
      @mechanism.set url, serializedJson

  ###*
    @param {string} url
    @return {Object.<string, Object>}
    @protected
  ###
  loadModels: (url) ->
    serializedJson = @mechanism.get url
    return null if !serializedJson
    este.json.parse serializedJson