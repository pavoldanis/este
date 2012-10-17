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

  suite 'defer', ->
    test 'should defer passed method call', (done) ->
      view.update = ->
        done()
      # useful for repeated events, for example bulk changes on collection
      # only last view.update is executed (Mocha checks repeated done() calls)
      view.defer view.update
      view.defer view.update
      view.defer view.update

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

  suite 'dispose', ->
    test 'should defer passed method call', (done) ->
      called = false
      view.update = ->
        called = true
      view.defer view.update
      view.dispose()
      setTimeout ->
        assert.isFalse called
        done()
      , 0