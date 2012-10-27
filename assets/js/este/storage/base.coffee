###*
  @fileoverview Base class for various sync/async storages. It defines common
  api for models/collections persitence.

###
goog.provide 'este.storage.Base'

goog.require 'goog.result'

class este.storage.Base

  ###*
    @param {string} namespace
    @constructor
  ###
  constructor: (@namespace) ->

  ###*
    @type {string}
  ###
  namespace: ''

  ###*
    @param {este.Model} model
    @param {string} id
    @return {!goog.result.Result}
  ###
  load: goog.abstractMethod

  ###*
    @param {este.Model} model
    @return {!goog.result.Result}
  ###
  save: goog.abstractMethod

  ###*
    @param {este.Model} model
    @return {!goog.result.Result}
  ###
  delete: goog.abstractMethod

  ###*
    @param {este.Collection} collection
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  query: goog.abstractMethod

  ###*
    This method maps event type to its method.
    todo: add tests once api will be stabilized
    @param {este.Model.Event} e
    at return {!goog.result.Result}
  ###
  saveChanges: (e) ->
    switch e.type
      when 'add'
        results = (@save added for added in e.added)
      when 'remove'
        results = (@delete removed for removed in e.removed)
      when 'change'
        results = [@save e.model]
      when 'update'
        return @saveChanges e.origin
      else
        goog.asserts.fail "Only add, remove, change, and update events are supported, not: #{e.type}."
    goog.result.combineOnSuccess.apply null, results

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
    @param {este.Model} model
    @protected
  ###
  checkModelUrn: (model) ->
    goog.asserts.assertString model.urn, 'model urn has to be string'

  ###*
    @param {este.Collection} collection
    @return {string}
    @protected
  ###
  checkCollectionUrn: (collection) ->
    urn = collection.getUrn()
    goog.asserts.assertString urn, 'collection.getUrn() has to be string'
    urn