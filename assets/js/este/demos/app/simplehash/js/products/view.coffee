###*
  @fileoverview este.demos.app.simplehash.products.View.
###
goog.provide 'este.demos.app.simplehash.products.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.simplehash.products.Collection'

class este.demos.app.simplehash.products.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  url: -> '/'

  ###*
    @type {este.demos.app.simplehash.products.Collection} products
    @protected
  ###
  products: null

  ###*
    @override
  ###
  load: (params) ->
    result = new goog.result.SimpleResult
    setTimeout =>
      @products ?= new este.demos.app.simplehash.products.Collection [
        name: 'Magic box', description: 'Something wonderful...'
      ,
        name: 'Blue table', description: 'Just a table.'
      ,
        name: 'Red light', description: 'You know it from district.'
      ]
      result.setValue true
    , 1000
    result

  ###*
    @override
  ###
  update: ->
    window['console']['log'] "products rendered"
    links = []
    for product in @products.toJson()
      # no url strings hardcoding, urls are always generated
      url = @createUrl este.demos.app.simplehash.product.View,
        id: product['_cid']
      links.push "<li><a href='#{url}'>#{url}</a>"

    @getElement().innerHTML = """
      <p>products</p>
      <ul>
        #{links.join ''}
      </ul>
    """
    return