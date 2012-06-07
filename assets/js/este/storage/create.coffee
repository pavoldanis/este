###*
  @fileoverview Storage factory
###
goog.provide 'este.storage.create'

goog.require 'goog.storage.mechanism.mechanismfactory'
goog.require 'goog.storage.Storage'

###*
  @param {string} key
  @return {goog.storage.Storage}
###
este.storage.create = (key) ->
  mechanism = goog.storage.mechanism.mechanismfactory.create 'este::' + key
  `mechanism = /** @type {goog.storage.mechanism.Mechanism} */ (mechanism)`
  return null if !mechanism
  new goog.storage.Storage mechanism