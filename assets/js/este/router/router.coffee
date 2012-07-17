###*
  @fileoverview Este Router. The router uses the same string-to-regexp
  conversion that Express does, so things like ":id", ":id?", and "*" work as
  you might expect.
  
  Another aspect that is much like Express is the ability to pass multiple
  callbacks. You can use this to your advantage to flatten nested callbacks,
  or simply to abstract components.

  Inspired from visionmedia/page.js

###
goog.provide 'este.Router'

goog.require 'goog.events.EventTarget'

###*
  @constructor
  @extends {goog.events.EventTarget}
###
este.Router = ->
  return

goog.inherits este.Router, goog.events.EventTarget
  
goog.scope ->
  `var _ = este.Router`

  ###*
    @param {string} path
    @param {(Function|Array.<Function>)} fns
  ###
  _::add = (path, fns) ->

  ###*
    @param {boolean=} dispatch perform initial dispatch
  ###
  _::start = (@dispatch = true) ->

  ###*
    Show path with optional state object.
    @param {string} path
    @param {Object} state
    @return {este.Page.Context}
  ###
  _::show = (path, state) ->
    null
    # todo, set token

  return
