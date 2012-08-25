suite 'este.app.View', ->

  View = este.app.View

  view = null

  setup ->
    view = new View

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf view, View

  suite 'load', ->
    test 'should call callback immediately', ->
      called = false
      view.load -> called = true
      assert.isTrue called

  suite 'dispatchLoad', ->
    test 'should dispatch load event with viewClass and params', (done) ->
      goog.events.listenOnce view, 'load', (e) ->
        assert.equal e.viewClass, 1
        assert.equal e.params, 2
        done()
      view.dispatchLoad 1, 2

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