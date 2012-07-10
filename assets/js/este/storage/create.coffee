###*
  @fileoverview Storage factory
###
goog.provide 'este.storage.create'

goog.require 'goog.storage.mechanism.mechanismfactory'
goog.require 'goog.storage.Storage'

###*
  @param {string} key e.g. este-ui-formspersister
  @param {boolean=} session
  @return {goog.storage.Storage}
###
este.storage.create = (key, session) ->
  factory = goog.storage.mechanism.mechanismfactory
  mechanism = if session
    factory.createHTML5SessionStorage key
  else
    factory.create key
  `mechanism = /** @type {goog.storage.mechanism.Mechanism} */ (mechanism)`
  return null if !mechanism
  new goog.storage.Storage mechanism