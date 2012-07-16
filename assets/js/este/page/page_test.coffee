suite 'este.Page', ->
  
  Page = este.Page
  page = null

  setup ->
    page = new este.Page

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf page, este.Page

  suite 'method X', ->
    test 'should do something', ->
      # todo
