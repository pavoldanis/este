suite 'este.mvc.App', ->

  App = este.mvc.App

  layout = null
  app = null
  view1 = null
  view2 = null
  view3 = null

  setup ->
    layout =
      setActive: (view) ->
    app = new App layout
    arrangeViews()

  arrangeViews = ->
    view1 = ->
    view1::fetch = (params, done) -> done()
    view2 = ->
    view2::fetch = (params, done) -> done()
    view3 = ->
    view3::fetch = (params, done) -> done()
    app.views = [view1, view2, view3]

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf app, App

  suite 'start', ->
    test 'should call fetch(params, done) on view1', (done) ->
      view1 = (app) ->
        fetch: (params, p_done) ->
          assert.isNull params
          assert.isFunction p_done
          done()
      app.views = [view1]
      app.start()

    test 'should not call fetch if silent start', ->
      called = false
      view1 = (app) ->
        fetch: (params, p_done) ->
          called = true
      app.views = [view1]
      app.start true
      assert.isFalse called

  suite 'show', ->
    test 'should call layout.setActive view1', (done) ->
      app.start()
      layout.setActive = (view) ->
        assert.instanceOf view, view1
        done()
      app.show view1

    test 'should dispatch fetch and fetched events', ->
      calls = []
      app.start()
      goog.events.listenOnce app, 'fetch', -> calls.push 1
      goog.events.listenOnce app, 'fetched', -> calls.push 2
      app.show view1
      assert.deepEqual calls, [1, 2]

    test 'should call layout.setActive view2', (done) ->
      app.start()
      layout.setActive = (view) ->
        assert.instanceOf view, view2
        done()
      app.show view2

  suite 'repeated show with same view', ->
    test 'show should cancel previous', (done) ->
      app.start()
      layout.setActive = (view) ->
        assert.instanceOf view, view1
        done()
      view1::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 5
      app.show view1
      setTimeout ->
        app.show view1
      , 1

  suite 'second show', ->
    test 'should cancel previous async', (done) ->
      app.start()
      layout.setActive = (view) ->
        assert.instanceOf view, view2
        done()
      view1::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 5
      app.show view1
      setTimeout ->
        app.show view2
      , 1

  suite 'three shows', ->
    test 'should cancel previous async', (done) ->
      app.start()
      layout.setActive = (view) ->
        assert.instanceOf view, view3
        done()
      view1::fetch = view2::fetch = view3::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 4
      app.show view1
      setTimeout ->
        app.show view2
        setTimeout ->
          app.show view3
        , 2
      , 2

  suite 'dispose', ->
    test 'should not call callbacks', (done) ->
      setActiveCalled = false
      app.start()
      layout.setActive = ->
        setActiveCalled = true
      view1::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 1
      app.show view1
      app.dispose()
      setTimeout ->
        assert.isFalse setActiveCalled
        done()
      , 5


