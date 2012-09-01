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
    @inheritDoc
  ###
  load: (done, params) ->
    # ajax call for data
    setTimeout =>
      done params
    , 2000

  ###*
    @inheritDoc
  ###
  render: (json) ->
    window['console']['log'] "product #{json['id']} rendered"
    @getElement().innerHTML = """
      <p>product, id = #{json['id']}</p>
      <a e-href>show products</a>
    """
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    @on @getElement(), 'click', @onClick

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onClick: (e) ->
    return if !e.target.hasAttribute 'e-href'
    # example of custom redirection
    @dispatchLoadEvent este.demos.app.simple.products.View