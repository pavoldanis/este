suite 'este.App', ->

  App = este.App

  view1 = null
  view2 = null
  view3 = null
  app = null

  setup ->
    view1 = createViewMock()
    view2 = createViewMock()
    view3 = createViewMock()
    app = new este.App
    app.addViews [view1, view2, view3]

  createViewMock = ->
    setParentEventTarget: ->
    show: ->

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf app, este.App

  suite 'start', ->
    test 'should call show on first view', (done) ->
      view1.show = ->
        done()
      app.start()

  # suite 'view loading', ->
  #   test 'should register view loaded event', ->
  #     app.start()
  #     goog.events.fireListeners view1, 'loading', false,
  #       type: 'loading'
  #       target: view1
  #     goog.events.fireListeners view1, 'loaded', false,
  #       type: 'loaded'
  #       target: view1

  #   test 'should cancel all pendings aka last click win', ->

  # suite 'view loaded', ->
  #   test 'should call layout setActive with target element', ->


  # todo: should remove element from parent element, or inject it back
  # suite 'show', ->
  #   test 'should call show on shown and hide on hidden views', ->
  #     count = 0
  #     view1.show = -> count++
  #     view2.hide = -> count++
  #     view3.hide = -> count++
  #     app.show view1
  #     assert.equal count, 3


