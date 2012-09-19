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

  suite 'redirect', ->
    test 'should dispatch redirect event with viewClass and params', (done) ->
      goog.events.listenOnce view, 'redirect', (e) ->
        assert.equal e.viewClass, 1
        assert.equal e.params, 2
        done()
      view.redirect 1, 2

  suite 'getElement', ->
    test 'should return element', ->
      element = view.getElement()
      assert.equal element.nodeType, 1

      sameElement = view.getElement()
      assert.equal element, sameElement

  suite 'dispose', ->
    test 'should remove element from DOM', ->
      element = view.getElement()
      parentNode = document.createElement 'div'
      parentNode.appendChild element
      view.dispose()
      assert.isNull element.parentNode

    test 'should call exitDocument', (done) ->
      view.exitDocument = ->
        done()
      view.dispose()

  suite 'getUrl', ->
    test 'should return null for view with null url', ->
      assert.isNull view.getUrl prototype: {}

    test 'should return url for view with url and params', ->
      viewClass = prototype: url: 'detail/:id'
      url = view.getUrl viewClass, id: 123
      assert.equal url, 'detail/123'

  suite 'isShown', ->
    test 'should return false', ->
      assert.isFalse view.isShown()

    test 'should return true after enterDocument', ->
      view.enterDocument()
      assert.isTrue view.isShown()

    test 'should return false after enterDocument, exitDocument', ->
      view.enterDocument()
      view.exitDocument()
      assert.isFalse view.isShown()

  suite 'on', ->
    test 'should throw exception if called before enterDocument', (done) ->
      try
        view.on {attachEvent: ->}, 'foo', ->
      catch e
        done()

    test 'should not throw exception if called after enterDocument', ->
      called = false
      view.enterDocument()
      try
        view.on {attachEvent: ->}, 'foo', ->
      catch e
        called = true
      assert.isFalse called

  suite 'exitDocument', ->
    test 'should call @getHandler().removeAll', (done) ->
      view.getHandler = ->
        removeAll: ->
          done()
      view.exitDocument()