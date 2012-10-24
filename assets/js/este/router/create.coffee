###*
  @fileoverview Router factory.
  @see ../demos/router.html
###
goog.provide 'este.router.create'

goog.require 'este.events.TapHandler'
goog.require 'este.History'
goog.require 'este.Router'
goog.require 'goog.string'
goog.require 'goog.Uri'

###*
  @param {Element=} element
  @param {string=} pathPrefix Should start and end with slash.
  @param {boolean=} forceHash
  @return {este.Router}
###
este.router.create = (element, pathPrefix, forceHash) ->
  pathPrefix ?= new goog.Uri(document.location.href).getPath()
  pathPrefix += '/' if !goog.string.endsWith pathPrefix, '/'

  history = new este.History pathPrefix, forceHash
  tapHandler = new este.events.TapHandler element ? document.body
  new este.Router history, tapHandler


