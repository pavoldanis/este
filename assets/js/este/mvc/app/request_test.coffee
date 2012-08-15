suite 'este.mvc.app.Request', ->

  Request = este.mvc.app.Request

  view = null
  params = null
  request = null

  setup ->
    view = {}
    params = {}
    request = new Request view, params

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf request, Request
      assert.equal request.view, view
      assert.equal request.params, params

  suite 'setViewData', ->
    test 'should set view viewData', ->
      request.setViewData 1
      assert.equal request.view.viewData, 1

  suite 'fetch', ->
    test 'todo', ->

  suite 'equal', ->
    test 'should check equality', ->
      assert.isFalse request.equal()

      anotherRequest = new Request 1, request.params
      assert.isFalse request.equal anotherRequest

      anotherRequest = new Request 1, 2
      assert.isFalse request.equal anotherRequest

