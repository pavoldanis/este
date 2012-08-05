suite 'este.App', ->

  App = este.App

  view = null
  app = null

  setup ->
    view = {}
    app = new este.App

  arrangeViews = ->
    app.addViews [view]

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf app, este.App

  suite 'addViews', ->
    test 'should set view app', ->
      arrangeViews()
      assert.equal view.app, app

  suite 'start', ->
    test 'should call show on first view', (done) ->
      arrangeViews()
      view.show = ->
        done()
      app.start()

  suite 'show', ->
    test 'should be function', ->
      assert.isFunction app.show

