###*
  @fileoverview este.demos.app.simple.detail.View.
###
goog.provide 'este.demos.app.simple.detail.View'

goog.require 'este.app.View'

class este.demos.app.simple.detail.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @inheritDoc
  ###
  url: 'detail/:id'

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
    window['console']['log'] "detail #{json['id']} rendered"
    @getElement().innerHTML = """
      <p>detail, id = #{json['id']}</p>
      <a e-href>back to listing</a>
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
    @dispatchLoadEvent este.demos.app.simple.listing.View