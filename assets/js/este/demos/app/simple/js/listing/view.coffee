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
      done [1, 2, 3]
    , 2000

  ###*
    @inheritDoc
  ###
  render: (ids) ->
    window['console']['log'] "listing rendered"

    links = []
    for id in ids
      # no url hardcoding, urls are always generated
      url = @getUrl este.demos.app.simple.detail.View, id: id
      links.push "<li><a e-href='#{url}'>#{url}</a>"

    @getElement().innerHTML = """
      <p>listing</p>
      <ul>
        #{links.join ''}
      </ul>
    """
    return