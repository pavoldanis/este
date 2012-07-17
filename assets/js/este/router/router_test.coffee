suite 'este.Router', ->
  
  Router = este.Router
  router = null

  setup ->
    router = new este.Router

    # pro regexy router.add

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf router, este.Router

    # test 'should work', ->
    #   router = new este.Router
    #     a: ->
    #     b: ->'

  suite 'method X', ->
    test 'should do something', ->
      # router.x()
