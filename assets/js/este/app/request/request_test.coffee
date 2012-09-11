suite 'este.app.Request', ->

  Request = este.app.Request

  view = null
  params = null
  request = null

  setup ->
    view = arrangeView()
    params = 1: 'foo'
    request = new Request view, params

  arrangeView = ->
    setParentEventTarget: ->

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf request, Request

  suite 'equal', ->
    test 'should equal same view and params', ->
      sameRequest = new Request view, params
      assert.isTrue request.equal sameRequest

    test 'should equal same view without params', ->
      request = new Request view
      sameRequest = new Request view
      assert.isTrue request.equal sameRequest

    test 'should not equal same view and different params', ->
      differentRequest = new Request view, 2: 'bla'
      assert.isFalse request.equal differentRequest

    test 'should not equal different view and same params', ->
      differentRequest = new Request arrangeView(), params
      assert.isFalse request.equal differentRequest