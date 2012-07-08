###*
  @fileoverview Just silly demo. Stay tuned for TodoMVC demo.
###

goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'
goog.require 'app.listing.Model.create'
goog.require 'app.listing.View'

goog.require 'goog.net.XhrIo'

app.start = ->

  if goog.DEBUG
    este.dev.Monitor.create()

  # model = app.listing.Model.create()

  # # less stupid example is in progress
  
  # view1 = new app.listing.View model
  # view1.render document.body

  # view1.getElement().style.color = 'blue'

  # # custom events test
  # goog.events.listen view1, 'componentclick', (e) ->
  #   alert 'component1 clicked'
  #   alert 'now it will be disposed, and removed from the dom, because it was rendered'
  #   view1.dispose()

# ensures the symbol will be visible after compiler renaming.
goog.exportSymbol 'app.start', app.start