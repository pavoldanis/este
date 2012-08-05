suite 'este.View', ->

  View = este.View

  app = null
  view = null

  setup ->
    app = {}
    view = new este.View
    view.app = app

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf view, este.View

  suite 'show', ->
    test 'should call app.show', (done) ->
      app.show = (_view) ->
        assert.equal _view, view
        done()
      view.show()
