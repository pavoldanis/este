###*
  @fileoverview este.demos.app.simplehash.products.Collection.
###
goog.provide 'este.demos.app.simplehash.products.Collection'

goog.require 'este.Collection'
goog.require 'este.demos.app.simplehash.product.Model'

class este.demos.app.simplehash.products.Collection extends este.Collection

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
  model: este.demos.app.simplehash.product.Model