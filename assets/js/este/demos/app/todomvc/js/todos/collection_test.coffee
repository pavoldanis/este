suite 'este.demos.app.todomvc.todos.Collection', ->

  Collection = este.demos.app.todomvc.todos.Collection

  collection = null

  setup ->
    json = [
      completed: false
    ,
      completed: false
    ]
    collection = new Collection json

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf collection, Collection

  suite 'toggleCompleted', ->
    test 'should set all items completed', ->
      assert.isFalse collection.at(0).get 'completed'
      assert.isFalse collection.at(1).get 'completed'
      collection.toggleCompleted true
      assert.isTrue collection.at(0).get 'completed'
      assert.isTrue collection.at(1).get 'completed'
      collection.toggleCompleted false
      assert.isFalse collection.at(0).get 'completed'
      assert.isFalse collection.at(1).get 'completed'

  suite 'clearCompleted', ->
    test 'should remove completed item from collection', ->
      assert.equal 2, collection.getLength()
      collection.at(0).set 'completed', true
      collection.clearCompleted()
      assert.equal 1, collection.getLength()
      assert.equal collection.at(0).get('completed'), false