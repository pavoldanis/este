###*
  @fileoverview Simple router factory.
  @see ../demos/simplerouter.html
###
goog.provide 'este.router.createSimpleRouter'

goog.require 'este.router.SimpleRouter'
goog.require 'este.History'

###*
  @param {string=} pathPrefix Path prefix to use if storing tokens in the path.
  The path prefix should start and end with slash.
  @return {este.router.SimpleRouter}
###
este.router.createSimpleRouter = (pathPrefix) ->
  history = new este.History pathPrefix
  router = new este.router.SimpleRouter history

  # router.add 'foo', (->), strict: false

  router

