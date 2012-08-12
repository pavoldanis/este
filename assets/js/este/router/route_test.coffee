suite 'este.router.Route', ->

  Route = este.router.Route

  route = null

  setup ->
    route = new Route '', (->), {}

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf route, Route

  testRoute = (path, url, show, hide) ->
    route = new Route path, show, hide: hide ? ->
    route.process url

  suite 'process', ->
    test 'user/:user - user/joe', (done) ->
      testRoute 'user/:user', 'user/joe', (params) ->
        assert.equal params['user'], 'joe'
        done()

    test 'users/:id? - users', (done) ->
      testRoute 'users/:id?', 'users', (params) ->
        assert.isUndefined params['id']
        done()

    test 'users/:id? - users/1', (done) ->
      testRoute 'users/:id?', 'users/1', (params) ->
        assert.equal params['id'], 1
        done()

    test 'assets/* - assets/este.js', (done) ->
      testRoute 'assets/*', 'assets/este.js', (fileName) ->
        assert.equal fileName, 'este.js'
        done()

    test 'assets/* - assets/js/este.js', (done) ->
      testRoute 'assets/*', 'assets/js/este.js', (path) ->
        assert.equal path, 'js/este.js'
        done()

    test 'assets/*.* - assets/este.js', (done) ->
      testRoute 'assets/*.*', 'assets/este.js', (params) ->
        assert.equal params[0], 'este'
        assert.equal params[1], 'js'
        done()

    test 'assets/*.* - assets/js/este.js', (done) ->
      testRoute 'assets/*.*', 'assets/js/este.js', (params) ->
        assert.equal params[0], 'js/este'
        assert.equal params[1], 'js'
        done()

    test 'user/:id/:operation? - user/1', (done) ->
      testRoute 'user/:id/:operation?', 'user/1', (params) ->
        assert.equal params['id'], 1
        assert.isUndefined params['operation']
        done()

    test 'user/:id/:operation? - user/1/edit', (done) ->
      testRoute 'user/:id/:operation?', 'user/1/edit', (params) ->
        assert.equal params['id'], 1
        assert.equal params['operation'], 'edit'
        done()

    test 'products.:format - products.json', (done) ->
      testRoute 'products.:format', 'products.json', (params) ->
        assert.equal params['format'], 'json'
        done()

    test 'products.:format - products.xml', (done) ->
      testRoute 'products.:format', 'products.xml', (params) ->
        assert.equal params['format'], 'xml'
        done()

    test 'products.:format? - products', (done) ->
      testRoute 'products.:format?', 'products', (params) ->
        assert.isUndefined params['format']
        done()

    test 'user/:id.:format? - user/12', (done) ->
      testRoute 'user/:id.:format?', 'user/12', (params) ->
        assert.equal params['id'], '12'
        assert.isUndefined params['format']
        done()

    test 'user/:id.:format? - user/12.json', (done) ->
      testRoute 'user/:id.:format?', 'user/12.json', (params) ->
        assert.equal params['id'], '12'
        assert.equal params['format'], 'json'
        done()

    test '/foo\/(\w+)\/(\w+)/ - foo/adam/eva', (done) ->
      testRoute /foo\/(\w+)\/(\w+)/, 'foo/adam/eva', (params) ->
        assert.equal params[0], 'adam'
        assert.equal params[1], 'eva'
        done()