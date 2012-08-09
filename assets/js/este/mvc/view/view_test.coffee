suite 'este.mvc.View', ->

  View = este.mvc.View

  show = null
  el = null
  view = null

  setup ->
    show = ->
    el = {}
    view = new View show, el

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf view, View
      assert.equal el, view.element

    test 'should work with show, el should be created', ->
      view = new View show
      assert.equal 1, view.element.nodeType

  suite 'fetch', ->
    test 'should call done callback', (done) ->
      view.fetch {}, ->
        done()