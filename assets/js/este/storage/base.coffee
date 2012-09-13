###*
  @fileoverview Base class for Este.js storages.
  todo
    consider make it as interface
###
goog.provide 'este.storage.Base'

goog.require 'goog.result'

class este.storage.Base

  ###*
    @param {string} root
    @constructor
  ###
  constructor: (root) ->

  ###*
    @type {string}
    @protected
  ###
  root: ''

  ###*
    @param {este.Model} model
    @return {goog.result.SimpleResult}
  ###
  save: goog.abstractMethod

  ###*
    @param {este.Model} model
    @param {string} id
    @return {goog.result.SimpleResult}
  ###
  load: goog.abstractMethod

  ###*
    @param {este.Model} model
    @return {goog.result.SimpleResult}
  ###
  delete: goog.abstractMethod

  ###*
    @param {este.Collection} collection
    @param {Object=} params
  ###
  query: goog.abstractMethod

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