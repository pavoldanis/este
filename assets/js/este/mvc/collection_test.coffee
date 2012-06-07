suite 'este.mvc.Collection', ->

  Collection = este.mvc.Collection
  Model = este.mvc.Model
  collection = null

  setup ->
    collection = new Collection

  suite 'constructor', ->
    test 'should optionally allow inject json data', ->
      json = [
        a: 1
      ,
        b: 2
      ]
      collection = new Collection json
      assert.deepEqual collection.toJson(), json

  suite 'model property', ->
    test 'should wrap json (meta test included)', ->
      Child = -> Model.apply @, arguments
      goog.inherits Child, Model
      Child::schema = c: meta: -> 'fok'
      json = [
        a: 1
      ,
        b: 2
      ]
      collection = new Collection json, Child
      assert.instanceOf collection.at(0), Child
      assert.equal collection.at(0).get('a'), 1
      assert.equal collection.at(1).get('b'), 2
      assert.equal collection.at(0).get('c'), 'fok'

    test 'should dispatch add event with models, not jsons', (done) ->
      collection = new Collection null, Model
      goog.events.listenOnce collection, 'add', (e) ->
        assert.instanceOf e.added[0], Model
        done()
      collection.add a: 1

    test 'toJson should serialize model', ->
      Child = -> Model.apply @, arguments
      goog.inherits Child, Model
      Child::schema = c: meta: -> 'fok'
      json = [
        id: 0
        a: 'aa'
      ,
        id: 1
        b: 'bb'
      ]
      collection = new Collection json, Child
      assert.deepEqual collection.toJson(), [
        id: 0
        a: 'aa'
        c: 'fok'
      ,
        id: 1
        b: 'bb'
        c: 'fok'
      ]

  suite 'add and remove', ->
    test 'should work', ->
      assert.equal collection.getLength(), 0
      collection.add 1
      assert.equal collection.getLength(), 1
      assert.isFalse collection.remove 2
      assert.isTrue collection.remove 1
      assert.equal collection.getLength(), 0

  suite 'add', ->
    test 'should fire add, change events', ->
      addCalled = changeCalled = false
      added = null
      goog.events.listenOnce collection, 'add', (e) ->
        added = e.added
        addCalled = true
      goog.events.listenOnce collection, 'change', ->
        changeCalled = true
      collection.add 1
      assert.isTrue addCalled
      assert.isTrue changeCalled
      assert.deepEqual added, [1]

  suite 'addMany', ->
    test 'should fire add, change events', ->
      addCalled = changeCalled = false
      added = null
      goog.events.listenOnce collection, 'add', (e) ->
        added = e.added
        addCalled = true
      goog.events.listenOnce collection, 'change', ->
        changeCalled = true
      collection.addMany [1, 2]
      assert.isTrue addCalled
      assert.isTrue changeCalled
      assert.deepEqual added, [1, 2]

  suite 'remove', ->
    test 'should fire remove, change events', ->
      removeCalled = changeCalled = false
      removed = null
      collection.add 1
      goog.events.listen collection, 'remove', (e) ->
        removed = e.removed
        removeCalled = true
      goog.events.listen collection, 'change', -> changeCalled = true
      collection.remove 1
      assert.isTrue removeCalled, 'removeCalled'
      assert.isTrue changeCalled, 'changeCalled'
      assert.deepEqual removed, [1]

    test 'should not fire remove, change events', ->
      removeCalled = changeCalled = false
      goog.events.listen collection, 'remove', -> removeCalled = true
      goog.events.listen collection, 'change', -> changeCalled = true
      collection.remove 1
      assert.isFalse removeCalled
      assert.isFalse changeCalled

  suite 'removeMany', ->
    test 'should fire remove, change events', ->
      removeCalled = changeCalled = false
      removed = null
      collection.add 1
      goog.events.listen collection, 'remove', (e) ->
        removed = e.removed
        removeCalled = true
      goog.events.listen collection, 'change', -> changeCalled = true
      collection.removeMany [1]
      assert.isTrue removeCalled, 'removeCalled'
      assert.isTrue changeCalled, 'changeCalled'
      assert.deepEqual removed, [1]

    test 'should not fire remove, change events', ->
      removeCalled = changeCalled = false
      goog.events.listen collection, 'remove', -> removeCalled = true
      goog.events.listen collection, 'change', -> changeCalled = true
      collection.removeMany [1]
      assert.isFalse removeCalled
      assert.isFalse changeCalled
      
  suite 'contains', ->
    test 'should return true if obj is present', ->
      assert.isFalse collection.contains 1
      collection.add 1
      assert.isTrue collection.contains 1

  suite 'removeIf', ->
    test 'should remove item', ->
      collection.add 1
      assert.isTrue collection.contains 1
      collection.removeIf (item) -> item == 1
      assert.isFalse collection.contains 1

  suite 'at', ->
    test 'should return item by index', ->
      collection.add 1
      assert.equal collection.at(0), 1

  suite 'toJson', ->
    test 'should return inner array', ->
      collection.add 1
      assert.deepEqual collection.toJson(), [1]

  suite 'bubbling events', ->
    test 'from inner collection should work', ->
      called = 0
      innerCollection = new Collection
      collection.add innerCollection
      goog.events.listen collection, 'change', (e) ->
        called++
      innerCollection.add 1
      assert.equal called, 1
      collection.remove innerCollection
      assert.equal called, 2
      innerCollection.add 1
      assert.equal called, 2

    test 'from inner model should work', ->
      called = 0
      innerModel = new Model
      collection.add innerModel
      goog.events.listen collection, 'change', (e) ->
        called++
      innerModel.set '1', 1
      assert.equal called, 1
      collection.remove innerModel
      assert.equal called, 2
      innerModel.set '1', 2
      assert.equal called, 2
      





      





















  

