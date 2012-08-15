###*
  @fileoverview este.mvc.app.create factory.
###
goog.provide 'este.mvc.app.create'

goog.require 'este.mvc.App'
goog.require 'este.mvc.Layout'
goog.require 'este.router.create'
goog.require 'goog.Uri'
goog.require 'goog.string'

###*
  @param {Element} element
  @param {Array.<function(new:este.mvc.View)>} views
  @param {string=} pathPrefix
  @param {boolean=} forceHash
###
este.mvc.app.create = (element, views, pathPrefix, forceHash) ->
  pathPrefix ?= new goog.Uri(document.location.href).getPath()
  pathPrefix += '/' if !goog.string.endsWith pathPrefix, '/'

  layout = new este.mvc.Layout element
  router = este.router.create element, pathPrefix, forceHash
  new este.mvc.App layout, views, router