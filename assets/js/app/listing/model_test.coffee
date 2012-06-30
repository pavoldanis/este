suite 'app.listing.Model', ->

  ###
    Tests are organized into tree steps:
      - arrange
      - act
      - assert

    But, they should be written from end!
    You will start with assert, then act, arrange is last!
  ###

  Model = app.listing.Model
  model = null

  setup ->
    # arrange
    model = new Model [1, 2]

  suite 'getItems', ->
    test 'should return passed value from constructor', ->
      # act
      items = model.getItems()
      
      # assert
      assert.deepEqual items, [
        id: 1
        text: 'mini'
        title: 'mini'
      ,
        id: 2
        text: 'mal'
        title: 'mal'
      ]

    test 'should use just two first numbers', ->
      # arrange
      model = new Model [1, 2, 3]

      # act
      items = model.getItems()
      
      # assert
      assert.deepEqual items, [
        id: 1
        text: 'mini'
        title: 'mini'
      ,
        id: 2
        text: 'mal'
        title: 'mal'
      ]