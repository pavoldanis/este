suite 'este.router.SimpleRouter', ->
  
  SimpleRouter = este.router.SimpleRouter
  history = null
  router = null

  setup ->
    history =
      setEnabled: ->
      addEventListener: ->
    router = new este.router.SimpleRouter history

  dispatchHistoryNavigateEvent = (token) ->
    goog.events.fireListeners history, 'navigate', false,
      type: 'navigate'
      token: token
      target: history

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf router, este.router.SimpleRouter

  suite 'start', ->
    test 'should call history.setEnabled with true', (done) ->
      history.setEnabled = (enabled) ->
        assert.isTrue enabled
        done()
      router.start()

  suite 'dispose', ->
    test 'should call history.dispose', (done) ->
      history.dispose = ->
        done()
      router.dispose()

  suite 'routing via history navigate event', ->
    suite 'show should work', ->
      testRoute = (path, token) ->
        test "path: '#{path}', token: '#{token}'", (done) ->
          router.add path, ->
            done()
          router.start()
          dispatchHistoryNavigateEvent token
      testRoute 'foo', 'foo'
      testRoute 'bla', 'bla'
      testRoute 'user/:user', 'user/joe'
      testRoute 'user/:user', 'user/satriani'

    suite 'hide should work', ->
      testRoute = (path, token) ->
        test "path: '#{path}' should match token: '#{token}'", (done) ->
          router.add path, (->), hide: ->
            done()
          router.start()
          dispatchHistoryNavigateEvent token
      testRoute 'foo', 'bla'
      testRoute 'bla', 'foo'
      testRoute 'user/:user', 'product/joe'
      testRoute 'user/:user', 'product/satriani'

    suite 'exception in callback', ->
      test 'should not break processing', ->
        count = 0
        router.add 'foo', ->
          count++
          throw 'Error'
        router.add 'foo', ->
          count++
        router.start()
        dispatchHistoryNavigateEvent 'foo'
        assert.equal count, 2

  suite 'pathname parsing', ->
    suite 'user/:user', ->
      test 'should work', (done) ->
        router.add 'user/:user', (params) ->
          assert.equal params['user'], 'joe'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'user/joe'

    suite 'users/:id?', ->
      test 'should work with undefined id', (done) ->
        router.add 'users/:id?', (params) ->
          assert.isUndefined params['id']
          done()
        router.start()
        dispatchHistoryNavigateEvent 'users'
    
      test 'should work with id', (done) ->
        router.add 'users/:id?', (params) ->
          assert.equal params['id'], 1
          done()
        router.start()
        dispatchHistoryNavigateEvent 'users/1'

    suite 'assets/*', ->
      test 'should work with fileName', (done) ->
        router.add 'assets/*', (fileName) ->
          assert.equal fileName, 'este.js'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'assets/este.js'

      test 'should work with dir/fileName', (done) ->
        router.add 'assets/*', (fileName) ->
          assert.equal fileName, 'js/este.js'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'assets/js/este.js'

    suite 'assets/*.*', ->
      test 'should work with fileName', (done) ->
        router.add 'assets/*.*', (params) ->
          assert.equal params[0], 'este'
          assert.equal params[1], 'js'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'assets/este.js'

      test 'should work with dir/fileName', (done) ->
        router.add 'assets/*.*', (params) ->
          assert.equal params[0], 'js/este'
          assert.equal params[1], 'js'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'assets/js/este.js'

    suite 'user/:id/:operation?', ->
      test 'should work without operation', (done) ->
        router.add 'user/:id/:operation?', (params) ->
          assert.equal params['id'], 1
          assert.isUndefined params['operation']
          done()
        router.start()
        dispatchHistoryNavigateEvent 'user/1'

      test 'should work with operation', (done) ->
        router.add 'user/:id/:operation?', (params) ->
          assert.equal params['id'], 1
          assert.equal params['operation'], 'edit'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'user/1/edit'

    suite 'products.:format', ->
      test 'should work for json', (done) ->
        router.add 'products.:format', (params) ->
          assert.equal params['format'], 'json'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'products.json'

      test 'should work for xml', (done) ->
        router.add 'products.:format', (params) ->
          assert.equal params['format'], 'xml'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'products.xml'

    suite 'products.:format?', ->
      test 'should work for json', (done) ->
        router.add 'products.:format?', (params) ->
          assert.equal params['format'], 'json'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'products.json'

      test 'should work for xml', (done) ->
        router.add 'products.:format?', (params) ->
          assert.equal params['format'], 'xml'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'products.xml'

      test 'should work with optional format', (done) ->
        router.add 'products.:format?', (params) ->
          assert.isUndefined params['format']
          done()
        router.start()
        dispatchHistoryNavigateEvent 'products'

    suite 'user/:id.:format?', ->
      test 'should work for id', (done) ->
        router.add 'user/:id.:format?', (params) ->
          assert.equal params['id'], '12'
          assert.isUndefined params['format']
          done()
        router.start()
        dispatchHistoryNavigateEvent 'user/12'

      test 'should work for id with extension', (done) ->
        router.add 'user/:id.:format?', (params) ->
          assert.equal params['id'], '12'
          assert.equal params['format'], 'json'
          done()
        router.start()
        dispatchHistoryNavigateEvent 'user/12.json'

  suite 'remove route', ->
    test 'should work for string route', ->
      called = false
      router.add 'user/:user', (params) ->
        assert.equal params['user'], 'joe'
        called = true
      router.start()
      router.remove 'user/:user'
      dispatchHistoryNavigateEvent 'user/joe'
      assert.isFalse called