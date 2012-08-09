suite 'este.mvc.Layout', ->

  Layout = este.mvc.Layout

  element = null
  layout = null
  view1el = null
  view1 = null
  view2el = null
  view2 = null

  setup ->
    element = document.createElement 'div'
    layout = new Layout element
    view1el = document.createElement 'div'
    view1 =
      element: view1el
      render: ->
      enterDocument: ->
      exitDocument: ->
    view2el = document.createElement 'div'
    view2 =
      element: view2el
      render: ->
      enterDocument: ->
      exitDocument: ->

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf layout, Layout

  suite 'setActive', ->
    test 'should append view1 element', (done) ->
      element.appendChild = (el) ->
        assert.equal el, view1el
        done()
      layout.setActive view1

    test 'should remove view1 element and append view2 element', ->
      layout.setActive view1
      layout.setActive view2
      assert.equal element.childNodes.length, 1
      assert.equal element.childNodes[0], view2.element

    test 'should call view render then enterDocument', ->
      calls = []
      view1.render = -> calls.push 1
      view1.enterDocument = -> calls.push 2
      layout.setActive view1
      assert.equal calls, '1,2'

    test 'should call exitDocument', (done) ->
      layout.setActive view1
      view1.exitDocument = ->
        done()
      layout.setActive view2
