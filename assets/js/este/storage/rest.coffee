###*
  @fileoverview REST JSON storage.

  todo
    inject labs xhr
    rename namespace prop
    XhrController.HEADERS = new goog.structs.Map
      'Content-Type': 'application/json;charset=utf-8'
###
goog.provide 'este.storage.Rest'

goog.require 'este.json'
goog.require 'este.result'
goog.require 'este.storage.Base'
goog.require 'goog.labs.net.xhr'
goog.require 'goog.object'
goog.require 'goog.string'

class este.storage.Rest extends este.storage.Base

  ###*
    @param {string} namespace
    @constructor
    @extends {este.storage.Base}
  ###
  constructor: (namespace) ->
    super namespace

  # ###*
  #   @override
  # ###
  # add: (model) ->
  #   # model toJson, resolve result, etc.
  #   # goog.labs.net.xhr.send 'POST', @namespace,
  #   este.result.ok()

  # ###*
  #   @override
  # ###
  # load: (model) ->
  #   este.result.ok()

  # ###*
  #   @override
  # ###
  # save: (model) ->
  #   este.result.ok()

  # ###*
  #   @override
  # ###
  # remove: (model) ->
  #   este.result.ok()

  # ###*
  #   @override
  # ###
  # query: (collection, params) ->
  #   este.result.ok()