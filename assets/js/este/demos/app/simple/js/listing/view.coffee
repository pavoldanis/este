###*
  @fileoverview este.demos.app.simple.listing.View.
###
goog.provide 'este.demos.app.simple.listing.View'

goog.require 'este.app.View'

class este.demos.app.simple.listing.View extends este.app.View

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
    # ajax call for data
    setTimeout =>
      done params
    , 2000

  ###*
    @inheritDoc
  ###
  render: ->
    window['console']['log'] "listing rendered"
    # todo: generate links, no links hardcoding
    # getLink este.demos.app.simple.detail.View, id: 1
    @getElement().innerHTML = """
      <p>listing</p>
      <ul>
        <li><a este-href='detail/1'>1</a>
        <li><a este-href='detail/2'>2</a>
        <li><a este-href='detail/3'>3</a>
      </ul>
    """
    return