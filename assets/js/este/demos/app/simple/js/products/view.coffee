###*
  @fileoverview este.demos.app.simple.products.View.
###
goog.provide 'este.demos.app.simple.products.View'

goog.require 'este.app.View'

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
    @inheritDoc
  ###
  load: (done, params) ->
    # products =

    # simulated sync ajax call
    setTimeout =>
      done [1, 2, 3]
    , 2000

  ###*
    @inheritDoc
  ###
  render: (ids) ->
    window['console']['log'] "products rendered"

    links = []
    for id in ids
      # no url hardcoding, urls are always generated
      url = @getUrl este.demos.app.simple.product.View, id: id
      links.push "<li><a e-href='#{url}'>#{url}</a>"

    @getElement().innerHTML = """
      <p>products</p>
      <ul>
        #{links.join ''}
      </ul>
    """
    return