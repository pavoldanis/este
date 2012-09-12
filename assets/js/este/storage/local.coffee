###*
  @fileoverview Local storage for este.Model's via HTML5 or IE user data.
  todo
    use goog.storage.mechanism.ErrorCode.QUOTA_EXCEEDED and check IE 64kb limit
    check if value was really stored
    version, scheme and updaters
    micro-optimize it via session cache
###
goog.provide 'este.storage.Local'

goog.require 'este.json'
goog.require 'este.storage.Base'
goog.require 'goog.asserts'
goog.require 'goog.result.SimpleResult'
goog.require 'goog.object'
goog.require 'goog.storage.mechanism.mechanismfactory'
goog.require 'goog.string'

class este.storage.Local extends este.storage.Base

  ###*
    @param {string} root
    @param {goog.storage.mechanism.Mechanism=} mechanism
    @param {function():string=} idFactory
    @constructor
    @extends {este.storage.Base}
  ###
  constructor: (@root, mechanism, idFactory) ->
    @mechanism = mechanism ?
      goog.storage.mechanism.mechanismfactory.create @root
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
    @param {este.Model} model
    @return {goog.result.SimpleResult}
  ###
  save: (model) ->
    @checkModelUrn model
    id = @ensureModelId model
    serializedModels = @mechanism.get model.urn
    models = if serializedModels then este.json.parse serializedModels else {}
    models[id] = model.toJson true, true
    @saveModels models, model.urn
    @returnSuccessResult id

  ###*
    @param {este.Model} model
    @return {goog.result.SimpleResult}
  ###
  load: (model) ->
    @checkModelUrn model
    id = @checkModelId model
    models = @loadModels model.urn
    return @returnErrorResult() if !models
    json = models[id]
    return @returnErrorResult() if !json
    model.fromJson json
    @returnSuccessResult id

  ###*
    @param {este.Model} model
    @return {goog.result.SimpleResult}
  ###
  delete: (model) ->
    @checkModelUrn model
    id = model.get 'id'
    if id
      models = @loadModels model.urn
      if models && models[id]
        delete models[id]
        @saveModels models, model.urn
        return @returnSuccessResult id.toString()
    @returnErrorResult()

  ###*
    @param {este.Collection} collection
    @param {Object=} params
    @return {goog.result.SimpleResult}
  ###
  query: (collection, params) ->
    # goog.asserts.assertString id, 'model id has to be string'
    null

  ###*
    @param {este.Model} model
    @return {string} model id
    @protected
  ###
  ensureModelId: (model) ->
    id = model.get 'id'
    return id.toString() if id?

    id = @idFactory()
    model.fromJson ('id': id), true
    id

  ###*
    @param {este.Model} model
    @return {string} model id
    @protected
  ###
  checkModelId: (model) ->
    id = model.get 'id'
    goog.asserts.assertString id, 'model id has to be string'
    id

  ###*
    @param {Object} models
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
    @return {Object}
    @protected
  ###
  loadModels: (urn) ->
    serializedJson = @mechanism.get urn
    return null if !serializedJson
    este.json.parse serializedJson

  ###*
    @param {string} id
    @return {goog.result.SimpleResult}
    @protected
  ###
  returnSuccessResult: (id) ->
    result = new goog.result.SimpleResult
    result.setValue id
    result

  ###*
    @return {goog.result.SimpleResult}
    @protected
  ###
  returnErrorResult: ->
    result = new goog.result.SimpleResult
    result.setError()
    result

  ###*
    @param {este.Model} model
    @protected
  ###
  checkModelUrn: (model) ->
    goog.asserts.assertString model.urn, 'model urn has to be string'