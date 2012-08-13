###*
  @fileoverview este.demos.labs.mvc2.detail.View.
###
goog.provide 'este.demos.labs.mvc2.detail.View'

goog.require 'este.mvc.View'

class este.demos.labs.mvc2.detail.View extends este.mvc.View

  ###*
    @constructor
    @extends {este.mvc.View}
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
  fetch: (@params, done) ->
    # ajax call for data
    setTimeout =>
      done()
    , 2000

  ###*
    @inheritDoc
  ###
  render: ->
    @element.innerHTML = """
      view: <b>detail, id = #{@params['id']}<br>
      <a href='#'>listing</a>
    """
    window['console']['log'] 'detail rendered'
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    @on @element, 'click', @onClick

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onClick: (e) ->
    return if e.target.tagName != 'A'
    e.preventDefault()
    @show este.demos.labs.mvc2.listing.View