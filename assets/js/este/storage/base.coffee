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