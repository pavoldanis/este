###*
  @fileoverview este.App factory.
###
goog.provide 'este.app.create'

goog.require 'este.App'
goog.require 'este.app.Layout'
goog.require 'este.router.create'
goog.require 'goog.Uri'
goog.require 'goog.string'

###*
  @param {Element} element
  @param {Array.<function(new:este.app.View)>} viewsClasses
  @param {string=} root
  @param {boolean=} forceHash
  @return {este.App}
###
este.app.create = (element, viewsClasses, root, forceHash) ->
  root ?= new goog.Uri(document.location.href).getPath()
  root += '/' if !goog.string.endsWith root, '/'

  views = (new viewClass for viewClass in viewsClasses)
  layout = new este.app.Layout element
  router = este.router.create element, root, forceHash

  new este.App views, layout, router