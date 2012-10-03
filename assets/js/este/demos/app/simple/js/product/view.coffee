###*
  @fileoverview este.demos.app.simple.product.View.
###
goog.provide 'este.demos.app.simple.product.View'

goog.require 'este.app.View'

class este.demos.app.simple.product.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: 'product/:id'

  ###*
    @type {Object}
    @protected
  ###
  params: null

  ###*
    @inheritDoc
  ###
  load: (@params = null) ->
    result = new goog.result.SimpleResult
    setTimeout =>
      result.setValue true
    , 2000
    result

  ###*
    @inheritDoc
  ###
  onLoad: ->
    window['console']['log'] "product #{@params['id']} rendered"
    @getElement().innerHTML = """
      <p>product, id = #{@params['id']}</p>
      <a e-href>show products</a>
    """
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @on @getElement(), 'click', @onClick

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onClick: (e) ->
    return if !e.target.hasAttribute 'e-href'
    # example of explicit redirection (without link with href)
    @redirect este.demos.app.simple.products.View