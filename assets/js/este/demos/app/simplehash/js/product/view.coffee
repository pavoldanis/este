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
    @override
  ###
  url: -> '/product/:id'

  ###*
    @type {Object}
    @protected
  ###
  params: null

  ###*
    @override
  ###
  load: (@params = null) ->
    result = new goog.result.SimpleResult
    setTimeout =>
      result.setValue true
    , 1000
    result

  ###*
    @override
  ###
  events: ->
    super()
    @on
      'button click': @onButtonClick

  ###*
    @override
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