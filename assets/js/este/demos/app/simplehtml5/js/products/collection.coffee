###*
  @fileoverview este.demos.app.simplehtml5.products.Collection.
###
goog.provide 'este.demos.app.simplehtml5.products.Collection'

goog.require 'este.Collection'
goog.require 'este.demos.app.simplehtml5.product.Model'

class este.demos.app.simplehtml5.products.Collection extends este.Collection

  ###*
    @param {Array=} array
    @constructor
    @extends {este.Collection}
  ###
  constructor: (array) ->
    super array

  ###*
    @inheritDoc
  ###
  model: este.demos.app.simplehtml5.product.Model