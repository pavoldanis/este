###*
  @fileoverview este.demos.app.simple.products.View.
###
goog.provide 'este.demos.app.simple.products.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.simple.products.Collection'

class este.demos.app.simple.products.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    '' is root.
    @inheritDoc
  ###
  url: ''

  ###*
    @type {este.demos.app.simple.products.Collection} products
    @protected
  ###
  products: null

  ###*
    @inheritDoc
  ###
  load: (params) ->
    result = new goog.result.SimpleResult
    setTimeout =>
      @products ?= new este.demos.app.simple.products.Collection [
        name: 'Magic box', description: 'Something wonderful...'
      ,
        name: 'Blue table', description: 'Just a table.'
      ,
        name: 'Red light', description: 'You know it from district.'
      ]
      result.setValue true
    , 2000
    result

  ###*
    @inheritDoc
  ###
  onLoad: ->
    window['console']['log'] "products rendered"
    links = []
    for product in @products.toJson()
      # no url hardcoding, urls are always generated
      url = @getUrl este.demos.app.simple.product.View, id: product['clientId']
      links.push "<li><a e-href='#{url}'>#{url}</a>"

    @getElement().innerHTML = """
      <p>products</p>
      <ul>
        #{links.join ''}
      </ul>
    """
    return