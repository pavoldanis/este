suite 'este.App', ->

  App = este.App

  view1 = null
  view2 = null
  view3 = null
  app = null

  setup ->
    arrangeViews()
    app.start()

  arrangeViews = ->
    view1 = createMockView true
    view2 = createMockView()
    view3 = createMockView()
    app = new App
    app.views = [
      view1
      view2
      view3
    ]

  createMockView = (noAsync) ->
    load: (done, json) ->
      if noAsync
        done json
        return
      setTimeout ->
        done json
      , 4
    onLoad: ->

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf app, App

  suite 'start', ->
    suite 'falsy', ->
      test 'should call view1 load then onLoad method', (done) ->
        arrangeViews()
        loadCalled = false
        view1.load = (done) ->
          loadCalled = true
          done foo: 'foo'
        view1.onLoad = (json) ->
          assert.isTrue loadCalled
          assert.deepEqual json, foo: 'foo', 'should pass json'
          done()
        app.start()

    suite 'truthy', ->
      test 'should not call view1 load', ->
        arrangeViews()
        loadCalled = false
        view1.load = (done) ->
          loadCalled = true
        app.start true
        assert.isFalse loadCalled

  suite 'load', ->
    suite 'view2', ->
      test 'should call view2.onLoad', (done) ->
        view2.onLoad = ->
          done()
        app.load view2

    suite 'view2 twice async', ->
      test 'should call view2.onLoad once', (done) ->
        view2.onLoad = ->
          done()
        app.load view2
        setTimeout ->
          app.load view2
        , 2

    suite 'view 2, view 3 async', ->
      test 'should call view3.onLoad', (done) ->
        view3.onLoad = ->
          done()
        app.load view2
        setTimeout ->
          app.load view3
        , 2

    suite 'view 2, view 3, view2 async', ->
      test 'should call view2.onLoad', (done) ->
        view2.onLoad = ->
          done()
        app.load view2
        setTimeout ->
          app.load view3
        , 2
        setTimeout ->
          app.load view2
        , 4