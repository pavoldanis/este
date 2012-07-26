###*
  @fileoverview Simple router factory.

  router = este.router.createSimpleRouter
    'about': ->
    'contact': ->
  router.start()
###
goog.provide 'este.router.createSimpleRouter'

goog.require 'este.router.SimpleRouter'
goog.require 'este.History'

###*
  @return {este.router.SimpleRouter}
###
este.router.createSimpleRouter = ->
  history = new este.History
  router = new este.router.SimpleRouter history
  # router.add 'foo', (->), strict: false

  router





