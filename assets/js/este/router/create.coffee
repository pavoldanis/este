###*
  @fileoverview Router factory.
  @see ../demos/router.html
###
goog.provide 'este.router.create'

goog.require 'este.History'
goog.require 'este.events.TapHandler'
goog.require 'este.router.Router'

###*
  @param {Element=} element
  @param {string=} pathPrefix Path prefix to use if storing tokens in the path.
  The path prefix should start and end with slash.
  @param {boolean=} forceHash
  @return {este.router.Router}
###
este.router.create = (element, pathPrefix, forceHash) ->
  history = new este.History pathPrefix, forceHash
  tapHandler = new este.events.TapHandler element ? document.body
  new este.router.Router history, tapHandler