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
  @param {este.router.Router=} router
  @return {este.App}
###
este.app.create = (element, viewsClasses, router) ->
  element = goog.dom.getElement element

  views = (new viewClass for viewClass in viewsClasses)
  layout = new este.app.Layout element
  router ?= este.router.create element
  new este.App views, layout, router