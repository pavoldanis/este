###*
  @fileoverview este.App factory.
###
goog.provide 'este.app.create'

goog.require 'este.App'

###*
  @param {Array.<este.app.View>} views
###
este.app.create = (views) ->
  app = new este.App
  app
  # make instances? pass it into constructor as Classes? hmm...
  # app.views =