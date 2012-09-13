suite 'este.Collection', ->

  # todo: sort compare tests

  Collection = este.Collection
  Model = este.Model
  Child = null
  collection = null

  setup ->
    collection = new Collection

  arrangeChildType = ->
    Child = -> Model.apply @, arguments
    goog.inherits Child, Model
    Child::schema = c: meta: -> 'fok'

  suite 'constructor', ->
    test 'should optionally allow inject json data', ->
      json = [
        a: 1
      ,
        b: 2
      ]
      collection = new Collection json
      assert.deepEqual collection.toJson(), json

    test 'should allow to override model', ->
      model = ->
      collection = new Collection null, model
      collection.add {}
      assert.instanceOf collection.at(0), model

  suite 'model property', ->
    test 'should wrap json (meta test included)', ->
      arrangeChildType()
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
      arrangeChildType()
      json = [
        id: 0
        a: 'aa'
      ,
        id: 1
        b: 'bb'
      ]
      collection = new Collection json, Child
      collectionJson = collection.toJson()
      delete cJson.clientId for cJson in collectionJson
      assert.deepEqual collectionJson, [
        id: 0
        a: 'aa'
        c: 'fok'
      ,
        id: 1
        b: 'bb'
        c: 'fok'
      ]

    test 'fromJson should deserialize model', ->
      collection = new Collection null, Model
      collection.fromJson [{1: 'a'}, {2: 'b'}]
      assert.instanceOf collection.at(0), Model
      assert.instanceOf collection.at(1), Model
      assert.isUndefined collection.at 2

  suite 'add, remove and getLength', ->
    test 'should work', ->
      assert.equal collection.getLength(), 0
      collection.add 1
      assert.equal collection.getLength(), 1
      assert.isFalse collection.remove 2
      assert.isTrue collection.remove 1
      assert.equal collection.getLength(), 0

  suite 'add item', ->
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

  suite 'add items', ->
    test 'should fire add, change events', ->
      addCalled = changeCalled = false
      added = null
      goog.events.listenOnce collection, 'add', (e) ->
        added = e.added
        addCalled = true
      goog.events.listenOnce collection, 'change', ->
        changeCalled = true
      collection.add [1, 2]
      assert.isTrue addCalled
      assert.isTrue changeCalled
      assert.deepEqual added, [1, 2]

  suite 'remove item', ->
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

  suite 'remove item', ->
    test 'should fire remove, change events', ->
      removeCalled = changeCalled = false
      removed = null
      collection.add 1
      goog.events.listen collection, 'remove', (e) ->
        removed = e.removed
        removeCalled = true
      goog.events.listen collection, 'change', -> changeCalled = true
      collection.remove [1]
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

  suite 'toArray', ->
    test 'should return inner array', ->
      collection.add 1
      assert.deepEqual collection.toArray(), [1]

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
        switch called
          when 0
            assert.equal e.changed[0], 1
          when 1
            assert.equal e.changed[0], innerCollection
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

  suite 'find', ->
    test 'should find item', ->
      collection.add [
        a: 1
      ,
        b: 2
      ]
      found = collection.find (item) -> item.a == 1
      assert.deepEqual found, a: 1
      found = collection.find (item) -> item.b == 2
      assert.deepEqual found, b: 2
      found = collection.find (item) -> item.b == 3
      assert.isUndefined found

  suite 'findById', ->
    test 'should find item by id', ->
      collection.add [
        id: 1
      ,
        id: 2
      ]
      found = collection.findById 1
      assert.deepEqual found, id: 1
      found = collection.findById 2
      assert.deepEqual found, id: 2
      found = collection.findById 3
      assert.isUndefined found

    test 'should find typed item by id', ->
      arrangeChildType()
      Child::schema = {}
      json = [
        id: 1
      ,
        id: 2
      ]

      collection = new Collection json, Child
      found = collection.findById 1
      json = found.toJson()
      delete json.clientId
      assert.deepEqual json, id: 1

      found = collection.findById 2
      json = found.toJson()
      delete json.clientId
      assert.deepEqual json, id: 2

      found = collection.findById 3
      assert.isUndefined found

  suite 'add typed object into typed collection', ->
    test 'should work', ->
      arrangeChildType()
      collection = new Collection [], Child
      child = new Child
      child.set 'a', 1
      collection.add child
      assert.instanceOf collection.at(0), Child
      assert.equal collection.at(0).get('a'), 1

  suite 'clear', ->
    test 'should works', ->
      count = 0
      collection = new Collection
      collection.add 1
      collection.add 2
      goog.events.listenOnce collection, 'change', -> count++
      goog.events.listenOnce collection, 'remove', -> count++
      collection.clear()
      assert.equal count, 2
      assert.isUndefined collection.at 0
      assert.isUndefined collection.at 1

  # todo:
  #   Collections with comparator functions will not automatically re-sort if you
  #   later change model attributes, so you may wish to call sort after changing
  #   model attributes that would affect the order.
  suite 'sorting', ->
    suite 'default compare', ->
      test 'should work with numbers', ->
        collection.add [3, 2, 1]
        assert.deepEqual collection.toJson(), [1, 2, 3]

      test 'should work with strings', ->
        collection.add ['c', 'b', 'a']
        assert.deepEqual collection.toJson(), ['a', 'b', 'c']
        collection.remove 'a'
        assert.deepEqual collection.toJson(), ['b', 'c']

    suite 'sort', ->
      test 'should fire change event', (done) ->
        goog.events.listenOnce collection, 'change', (e) ->
          done()
        collection.sort()

      suite 'by', ->
        test 'before should work', ->
          collection.sort by: (item) -> item.id
          collection.add id: 3
          collection.add id: 1
          collection.add id: 2
          assert.deepEqual collection.toJson(), [{id: 1}, {id: 2}, {id: 3}]

        test 'before should not(!) work', ->
          collection.sort by: null
          collection.add id: 3
          collection.add id: 2
          collection.add id: 1
          assert.deepEqual collection.toJson(), [{id: 3}, {id: 2}, {id: 1}]

        test 'after should work', ->
          collection.add id: 3
          collection.add id: 1
          collection.add id: 2
          collection.sort by: (item) -> item.id
          assert.deepEqual collection.toJson(), [{id: 1}, {id: 2}, {id: 3}]

      # todo
      # suite 'compare', ->

      suite 'reversed', ->
        test 'before should work', ->
          collection.sort
            by: (item) -> item.id
            reversed: true
          collection.add id: 3
          collection.add id: 1
          collection.add id: 2
          assert.deepEqual collection.toJson(), [{id: 3}, {id: 2}, {id: 1}]

        test 'after should work', ->
          collection.add id: 'c'
          collection.add id: 'a'
          collection.add id: 'b'
          collection.sort
            by: (item) -> item.id
            reversed: true
          assert.deepEqual collection.toJson(), [{id: 'c'}, {id: 'b'}, {id: 'a'}]

  suite 'subclassed collection', ->
    test 'should allow to define model as property', ->
      ChildCollection = (array, model) ->
        goog.base @, array, model
        return
      goog.inherits ChildCollection, Collection
      ChildCollection::model = Child
      collection = new ChildCollection
      assert.equal collection.model, Child

  # suite 'filter', ->
  #   test 'should work', ->
  #     collection.filter (item) ->