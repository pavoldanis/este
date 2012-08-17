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
      add: ->
      pathNavigate: (url, params, silent) ->
      start: ->
    app = new App layout, [], router
    arrangeViews()

  arrangeViews = ->
    view1 = ->
    view1::url = 'test'
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
    suite 'urlProjectionEnabled == true', ->
      test 'should call router.start', ->
        called = false
        router.start = -> called = true
        app.start()
        assert.isTrue called

    suite 'urlProjectionEnabled == false', ->
      test 'should not call router.start', ->
        called = false
        router.start = -> called = true
        app.urlProjectionEnabled = false
        app.start()
        assert.isFalse called

      test 'should fetch first view', (done) ->
        view1::fetch = ->
          done()
        app.urlProjectionEnabled = false
        app.start()

  suite 'show', ->
    test 'should call layout.setActive view1', (done) ->
      app.start()
      layout.setActive = (view) ->
        assert.instanceOf view, view1
        done()
      app.show view1

    suite 'view.url = "fok"', ->
      test 'should call router.pathNavigate', (done) ->
        app.start()
        view1::url = 'fok'
        params = {}
        router.pathNavigate = (url, p_params, silent) ->
          assert.equal url, 'fok'
          assert.equal p_params, params
          assert.isTrue silent
          done()
        app.show view1, params

    suite 'view.url = ""', ->
      test 'should call router.pathNavigate', (done) ->
        app.start()
        view1::url = ''
        params = {}
        router.pathNavigate = (url, p_params, silent) ->
          assert.equal url, ''
          assert.equal p_params, params
          assert.isTrue silent
          done()
        app.show view1, params

    test 'should dispatch beforeviewshow and afterviewshow events', ->
      calls = []
      app.start()
      goog.events.listenOnce app, 'beforeviewshow', (e) ->
        assert.instanceOf e.request.view, view1
        assert.deepEqual e.request.params, id: 123
        calls.push 1
      goog.events.listenOnce app, 'afterviewshow', (e) ->
        assert.instanceOf e.request.view, view1
        assert.deepEqual e.request.params, id: 123
        calls.push 2
      app.show view1, id: 123
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

  suite 'router show callback', ->
    test 'should call view.fetch', (done) ->
      show = null
      router.add = (path, p_show) ->
        show = p_show
      view1::fetch = ->
        done()
      app.start()
      show()

    test 'should not call router.pathNavigate', ->
      show = null
      called = false
      router.add = (path, p_show) ->
        show = p_show
      router.pathNavigate = ->
        called = true
      app.start()
      show()
      assert.isFalse called