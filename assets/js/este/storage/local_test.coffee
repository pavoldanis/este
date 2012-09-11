suite 'este.storage.Local', ->

  Local = este.storage.Local

  root = null
  mechanism = null
  idFactory = null
  model = null
  local = null

  setup ->
    root = ''
    mechanism =
      set: (key, value) ->
        @[key] = value
      get: (key) ->
        @[key]
      remove: (key) ->
        delete @[key]
    idFactory = -> 'someUniqueId'
    model =
      urn: 'model'
      set: (key, value) ->
        @[key] = value
      get: (key) ->
        @[key]
      toJson: ->
        # to remove methods
        este.json.parse este.json.stringify @
      fromJson: (json) ->
        for k, v of json
          @[k] = json
        return

    local = new Local root, mechanism, idFactory

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf local, Local

  suite 'save', ->
    test 'should assign id for model without id', (done) ->
      model.fromJson = (json, forceIds) ->
        assert.deepEqual json, id: 'someUniqueId'
        assert.isTrue forceIds
        done()
      local.save model

    test 'should not assign id for model with id', ->
      called = false
      model.get = (key) ->
        return '123' if key == 'id'
      model.fromJson = (json, forceIds) ->
        called = true
      local.save model
      assert.isFalse called

    test 'should store json to mechanism', (done) ->
      mechanism.set = (key, value) ->
        assert.equal key, 'model'
        assert.equal value, '{"someUniqueId":{"foo":"bla"}}'
        done()
      model.toJson = (noMetas, noId) ->
        assert.isTrue noMetas
        assert.isTrue noId
        foo: 'bla'
      local.save model

    test 'should return success result with id', (done) ->
      result = local.save model
      goog.labs.result.waitOnSuccess result, (value) ->
        assert.equal value, 'someUniqueId'
        done()

  suite 'load', ->
    test 'should throw exception for model without id', (done) ->
      try
        local.load model
      catch e
        assert.instanceOf e, Error
        done()

    test 'should not throw exception for model with id', ->
      called = false
      model.id = '123'
      try
        local.load model
      catch e
        called = true
      assert.isFalse called

    test 'should mechanism.get model', (done) ->
      getKey = null
      mechanism.get = (key) ->
        assert.equal key, 'model'
        done()
      model.id = '123'
      local.load model

    test 'should load model', (done) ->
      mechanism.get = (key) ->
        assert.equal key, 'model'
        '{"123":{"foo":"bla"}}'
      model.id = '123'
      model.fromJson = (json) ->
        assert.deepEqual json,
          foo: 'bla'
        done()
      local.load model

    test 'should return success result with id', (done) ->
      mechanism.get = (key) -> '{"123":{"foo":"bla"}}'
      model.id = '123'
      result = local.load model
      goog.labs.result.waitOnSuccess result, (value) ->
        assert.equal value, '123'
        done()

    test 'should return error result if storage does not exists', (done) ->
      mechanism.get = (key) -> ''
      model.id = '123'
      result = local.load model
      goog.labs.result.waitOnError result, ->
        done()

    test 'should return error result if storage item does not exists', (done) ->
      mechanism.get = (key) -> '{"123":{"foo":"bla"}}'
      model.id = '789'
      result = local.load model
      goog.labs.result.waitOnError result, ->
        done()

  # suite 'delete', ->
  #   test 'should delete model from storage', (done) ->
  #     mechanism.get = (key) -> '{"$123":{"foo":"bla"}}'
  #     mechanism.set = (key, value) ->
  #       assert.equal key, 'model'
  #       assert.equal value, '{}'
  #       done()
  #     model.id = '123'
  #     result = local.delete model

  suite 'delete', ->
    test 'should delete model from storage', (done) ->
      mechanism.get = (key) -> '{"123":{"foo":"bla"}}'
      mechanism.remove = (key) ->
        assert.equal key, 'model'
        done()
      model.id = '123'
      result = local.delete model

    test 'should return success result with id', (done) ->
      mechanism.get = (key) -> '{"123":{"foo":"bla"}}'
      model.id = '123'
      result = local.delete model
      goog.labs.result.waitOnSuccess result, (value) ->
        assert.equal value, '123'
        done()

    test 'should return error result for model without id', (done) ->
      mechanism.get = (key) -> '{"123":{"foo":"bla"}}'
      result = local.delete model
      goog.labs.result.waitOnError result, ->
        done()

    test 'should return error result if storage does not exists', (done) ->
      mechanism.get = (key) -> ''
      model.id = '456'
      result = local.delete model
      goog.labs.result.waitOnError result, ->
        done()

    test 'should return error result if item does not exists', (done) ->
      mechanism.get = (key) -> '{"123":{"foo":"bla"}}'
      model.id = '456'
      result = local.delete model
      goog.labs.result.waitOnError result, ->
        done()