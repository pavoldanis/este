suite 'este.View', ->

  View = este.View

  view = null

  setup ->
    view = new este.View

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf view, este.View