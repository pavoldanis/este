###*
  @fileoverview Simple router factory.
  @see ../demos/simplerouter.html
###
goog.provide 'este.router.createSimpleRouter'

goog.require 'este.History'
goog.require 'este.events.TapHandler'
goog.require 'este.router.SimpleRouter'

###*
  @param {Element} element
  @param {string=} pathPrefix Path prefix to use if storing tokens in the path.
  The path prefix should start and end with slash.
  @param {boolean=} forceHash
  @return {este.router.SimpleRouter}
###
este.router.createSimpleRouter = (element, pathPrefix, forceHash) ->
  history = new este.History pathPrefix, forceHash
  tapHandler = new este.events.TapHandler element
  new este.router.SimpleRouter history, tapHandler

