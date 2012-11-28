###*
  @fileoverview Base class for various sync/async storages. It defines common
  API for models persistence. Since one of the most expensive operations in
  an application is making remote calls, this class allows you to override
  processQueue method, to enable batching all write calls to the server into
  a single call.
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
    @param {este.Model} model
    @param {este.Collection|string=} arg
    @return {string}
  ###
  @getUrl: (model, arg) ->
    return model.getUrl() if !arg
    return arg.getUrl() if arg instanceof este.Collection
    arg

  ###*
    @type {string}
  ###
  namespace: ''

  ###*
    @type {Array.<Object>}
    @protected
  ###
  queue: null

  ###*
    @param {este.Model} model
    @param {este.Collection|string=} arg
    @return {goog.result.Result}
  ###
  add: (model, arg) ->
    url = Base.getUrl model, arg
    return @addInternal model, url if !@queue
    @enqueue 'add', model, url

  ###*
    @param {este.Model} model
    @param {este.Collection|string=} arg
    @return {goog.result.Result}
  ###
  load: (model, arg) ->
    url = Base.getUrl model, arg
    @loadInternal model, url

  ###*
    @param {este.Model} model
    @param {este.Collection|string=} arg
    @return {goog.result.Result}
  ###
  save: (model, arg) ->
    url = Base.getUrl model, arg
    return @saveInternal model, url if !@queue
    @enqueue 'save', model, url

  ###*
    @param {este.Model} model
    @param {este.Collection|string=} arg
    @return {goog.result.Result}
  ###
  remove: (model, arg) ->
    url = Base.getUrl model, arg
    return @removeInternal model, url if !@queue
    @enqueue 'remove', model, url

  ###*
    @param {este.Collection} collection
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  query: (collection, params) ->
    @queryInternal collection, params

  ###*
    Allows to perform basic CRUD operations within a Unit of Work. It is
    important to note that no changes will be saved until saveChanges method
    is called.
  ###
  openSession: ->
    return if @queue
    @queue = []

  ###*
    Save all queued changes.
    @return {!goog.result.Result}
  ###
  saveChanges: ->
    queue = @queue.slice 0
    @queue = null
    @processQueue queue

  ###*
    @param {este.Model.Event} e
    @return {goog.result.Result}
  ###
  saveChangesFromEvent: (e) ->
    e = e.origin if e.type == 'update'
    results = []
    # todo: use full qualified event types
    switch e.type
      when 'add'
        for added in e.added
          result = @add added
          results.push result if result
      when 'remove'
        for removed in e.removed
          result = @remove removed
          results.push result if result
      when 'change'
        result = @save e.model
        results.push result if result
      else
        goog.asserts.fail "Unsupported event type: #{e.type}."
    if results.length
      return goog.result.combineOnSuccess.apply @, results
    null

  ###*
    @param {este.Model} model
    @param {string} url
    @return {!goog.result.Result}
    @protected
  ###
  addInternal: goog.abstractMethod

  ###*
    @param {este.Model} model
    @param {string} url
    @return {!goog.result.Result}
    @protected
  ###
  loadInternal: goog.abstractMethod

  ###*
    @param {este.Model} model
    @param {string} url
    @return {!goog.result.Result}
    @protected
  ###
  saveInternal: goog.abstractMethod

  ###*
    @param {este.Model} model
    @param {string} url
    @return {!goog.result.Result}
    @protected
  ###
  removeInternal: goog.abstractMethod

  ###*
    @param {este.Collection} collection
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  queryInternal: goog.abstractMethod

  ###*
    @param {string} method
    @param {este.Model} model
    @param {string} url
    @protected
  ###
  enqueue: (method, model, url) ->
    @queue.push
      method: method
      model: model
      url: url
    null

  ###*
    @param {Array.<Object>} queue
    @return {!goog.result.Result}
    @protected
  ###
  processQueue: (queue) ->
    results = []
    for command in queue
      result = switch command.method
        when 'add'
          @addInternal command.model, command.url
        when 'save'
          @saveInternal command.model, command.url
        when 'remove'
          @removeInternal command.model, command.url
      results.push result
    if results.length
      return goog.result.combineOnSuccess.apply @, results
    este.result.ok()