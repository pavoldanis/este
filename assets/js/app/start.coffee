goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'
goog.require 'app.listing.Model.create'
goog.require 'app.listing.View'

app.start = ->
  if goog.DEBUG
    este.dev.Monitor.create()

  model = app.listing.Model.create()

  # rendering example
  view1 = new app.listing.View model
  view1.render document.body

  # decoration example
  view2 = new app.listing.View model
  view2.decorate document.body

  # custom events test
  goog.events.listen view1, 'componentclick', (e) ->
    alert 'component1 clicked'
    alert 'now it will be disposed, and removed from the dom, because it was rendered'
    view1.dispose()

  goog.events.listen view2, 'componentclick', (e) ->
    alert 'component1 clicked'
    alert 'now it will be disposed, but will stay in dom, because it was decorated'
    view2.dispose()

# ensures the symbol will be visible after compiler renaming.
goog.exportSymbol 'app.start', app.start