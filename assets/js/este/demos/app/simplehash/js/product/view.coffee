###*
  @fileoverview este.demos.app.simplehash.product.View.
###
goog.provide 'este.demos.app.simplehash.product.View'

goog.require 'este.app.View'

class este.demos.app.simplehash.product.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: '/product/:id'

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
    , 1000
    result

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @update()
    @on 'button', 'click', @onButtonClick

  ###*
    @inheritDoc
  ###
  update: ->
    window['console']['log'] "product #{@params['id']} rendered"
    @getElement().innerHTML = """
      <p>product, id = #{@params['id']}</p>
      <button>show all products</button>
    """
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onButtonClick: (e) ->
    # example of explicit redirection without element with href
    @redirect este.demos.app.simplehash.products.View