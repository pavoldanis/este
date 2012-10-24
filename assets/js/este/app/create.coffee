###*
  @fileoverview este.App factory.
###
goog.provide 'este.app.create'

goog.require 'este.App'
goog.require 'este.app.Layout'
goog.require 'este.router.create'

###*
  @param {string|Element} element
  @param {Array.<function(new:este.app.View)>} viewsClasses
  @param {boolean=} forceHash
  @return {este.App}
###
este.app.create = (element, viewsClasses, forceHash) ->
  element = goog.dom.getElement element
  views = (new viewClass for viewClass in viewsClasses)
  layout = new este.app.Layout element
  router = este.router.create element, undefined, forceHash
  new este.App views, layout, router