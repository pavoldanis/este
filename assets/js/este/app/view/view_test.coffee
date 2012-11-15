suite 'este.app.View', ->

  View = este.app.View

  view = null

  setup ->
    view = new View

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf view, View

  suite 'load', ->
    test 'should return successful result', ->
      result = view.load id: 1
      assert.deepEqual result.getValue(), id: 1
      assert.equal result.getState(), goog.result.Result.State.SUCCESS

  suite 'redirect', ->
    test 'should dispatch redirect event with viewClass and params', (done) ->
      goog.events.listenOnce view, 'redirect', (e) ->
        assert.equal e.viewClass, 1
        assert.equal e.params, 2
        done()
      view.redirect 1, 2

  suite 'getUrl', ->
    test 'should return null for view with null url', ->
      assert.isNull view.getUrl prototype: {}

    test 'should return url for view with url and params', ->
      viewClass = prototype: url: 'detail/:id'
      url = view.getUrl viewClass, id: 123
      assert.equal url, 'detail/123'

  suite 'mergeHtml', ->
    test 'should call este.dom.merge', (done) ->
      _merge = este.dom.merge
      html = ''
      este.dom.merge = (el, html) ->
        este.dom.merge = _merge
        assert.equal el, view.getElement()
        assert.equal html, 'html'
        done()
      view.mergeHtml 'html'