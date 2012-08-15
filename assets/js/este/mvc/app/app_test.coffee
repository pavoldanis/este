suite 'este.mvc.App', ->

  App = este.mvc.App

  layout = null
  router = null
  app = null
  view1 = null
  view2 = null
  view3 = null

  setup ->
    layout =
      setActive: (view) ->
    router =
      pathNavigate: (url, params) ->
      start: ->
    app = new App layout, [], router
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

    suite 'view.url = "fok"', ->
      test 'should call router.pathNavigate url, p_params', (done) ->
        app.start()
        view1::url = 'fok'
        params = {}
        router.pathNavigate = (url, p_params) ->
          assert.equal url, 'fok'
          assert.equal p_params, params
          done()
        app.show view1, params

    suite 'view.url = ""', ->
      test 'should call router.pathNavigate url, p_params', (done) ->
        app.start()
        view1::url = ''
        params = {}
        router.pathNavigate = (url, p_params) ->
          assert.equal url, ''
          assert.equal p_params, params
          done()
        app.show view1, params

    test 'should dispatch beforeviewshow and afterviewshow events', ->
      calls = []
      app.start()
      goog.events.listenOnce app, 'beforeviewshow', -> calls.push 1
      goog.events.listenOnce app, 'afterviewshow', -> calls.push 2
      app.show view1
      assert.deepEqual calls, [1, 2]

    test 'should call layout.setActive view2', (done) ->
      app.start()
      layout.setActive = (view, params) ->
        assert.instanceOf view, view2
        assert.deepEqual params, id: 1
        done()
      app.show view2, id: 1

  suite 'repeated show with same view and params', ->
    test 'show should cancel next', (done) ->
      app.start()
      layout.setActive = (view, params) ->
        assert.instanceOf view, view1
        assert.deepEqual params, id: 2
        done()
      view1::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 5
      app.show view1, id: 2
      setTimeout ->
        app.show view1, id: 2
      , 1

  suite 'repeated show with same view and different params', ->
    test 'show should cancel previous', (done) ->
      app.start()
      layout.setActive = (view, params) ->
        assert.instanceOf view, view1
        assert.deepEqual params, id: 3
        done()
      view1::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 5
      app.show view1, id: 2
      setTimeout ->
        app.show view1, id: 3
      , 1

  suite 'second show', ->
    test 'should cancel previous', (done) ->
      app.start()
      layout.setActive = (view, params) ->
        assert.instanceOf view, view2
        assert.deepEqual params, id: 5
        done()
      view1::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 5
      app.show view1, id: 4
      setTimeout ->
        app.show view2, id: 5
      , 1

  suite 'three shows', ->
    test 'should cancel previous', (done) ->
      app.start()
      layout.setActive = (view, params) ->
        assert.instanceOf view, view3
        assert.deepEqual params, id: 8
        done()
      view1::fetch = view2::fetch = view3::fetch = (params, p_done) ->
        setTimeout ->
          p_done()
        , 4
      app.show view1, id: 6
      setTimeout ->
        app.show view2, id: 7
        setTimeout ->
          app.show view3, id: 8
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