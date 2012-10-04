suite 'este.app.Layout', ->

  Layout = este.app.Layout

  element = null
  layout = null
  view1 = null
  view2 = null

  setup ->
    element = document.createElement 'div'
    layout = new Layout element
    view1 = createMockView()
    view2 = createMockView()

  createMockView = ->
    element: null
    getElement: -> @element
    render: -> @element = document.createElement 'div'
    enterDocument: ->
    exitDocument: ->

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf layout, Layout

  suite 'show', ->
    suite 'not yet rendered view', ->
      test 'should call render', (done) ->
        view1.render = (el) ->
          assert.equal el, layout.element
          done()
        layout.show view1

    suite 'rendered view', ->
      test 'should call enterDocument', (done) ->
        view1.render()
        view1.enterDocument = ->
          done()
        layout.show view1

      test 'should set element.style.display to empty string', ->
        view1.render()
        layout.show view1
        assert.strictEqual view1.getElement().style.display, ''

    suite 'previous view', ->
      test 'should call exitDocument', (done) ->
        view1.exitDocument = ->
          done()
        layout.show view1
        layout.show view2

      test 'should set element.style.display to none', ->
        layout.show view1
        layout.show view2
        assert.strictEqual view1.getElement().style.display, 'none'