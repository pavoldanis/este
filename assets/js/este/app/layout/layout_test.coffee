suite 'este.app.Layout', ->

  Simple = este.app.Layout

  element = null
  simple = null
  view1 = null
  view2 = null

  setup ->
    element = document.createElement 'div'
    simple = new Simple element
    view1 = createMockView()
    view2 = createMockView()

  createMockView = ->
    getElement: -> @element ?= document.createElement 'div'
    enterDocument: ->
    exitDocument: ->

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf simple, Simple

  suite 'show view', ->
    test 'should call enterDocument', (done) ->
      view1.enterDocument = ->
        done()
      simple.show view1

    test 'should append view.getElement() into layout element', (done) ->
      element.appendChild = (el) ->
        assert.equal el, view1.getElement()
        done()
      simple.show view1

    test 'should set element.style.display to empty string', ->
      simple.show view1
      assert.strictEqual view1.getElement().style.display, ''

    test 'should set previous element.style.display to none', ->
      simple.show view1
      simple.show view2
      assert.strictEqual view1.getElement().style.display, 'none'

    test 'should not reappend yet injected view', ->
      called = false
      simple.show view1
      element.appendChild = ->
        called = true
      simple.show view1
      assert.isFalse called

    test 'should call enterDocument after append', (done) ->
      view1.enterDocument = ->
        assert.isNotNull view1.getElement().parentNode
        done()
      simple.show view1

    test 'should call exitDocument on previous', (done) ->
      view1.exitDocument = ->
        assert.isNotNull view1.getElement().parentNode
        done()
      simple.show view1
      simple.show view2