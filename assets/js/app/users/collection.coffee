###*
  @fileoverview List of users.
###
goog.provide 'app.users.Collection'

goog.require 'este.mvc.Collection'

###*
  @param {Array=} array
  @param {Function=} model
  @constructor
  @extends {este.mvc.Collection}
###
app.users.Collection = (array, model) ->
  goog.base @, array, model
  return

goog.inherits app.users.Collection, este.mvc.Collection
  
goog.scope ->
  `var _ = app.users.Collection`

  return
