suite 'este.Locale', ->

  suite 'instance test', ->
    locale = new este.Locale ' ', ',', 2, ' Kč', false
    test 'locale.number_format', ->
      str = locale.number_format 123, 0
      assert.equal '123', str

      str = locale.number_format 123.456, 0
      assert.equal '123', str

      str = locale.number_format 123.456, 2
      assert.equal '123,46', str

      str = locale.number_format 98123.456, 2
      assert.equal '98 123,46', str

    test 'locale.formatPrice', ->
      str = locale.formatPrice 123, 0
      assert.equal '123,00 Kč', str

      str = locale.formatPrice 123.4, 0
      assert.equal '123,40 Kč', str

      str = locale.formatPrice 123.45, 0
      assert.equal '123,45 Kč', str
  
  suite 'instance test', ->
    locale = new este.Locale(',', '.', 2, '$', true)
    test 'locale.number_format', ->
      str = locale.number_format 123, 0
      assert.equal '123', str

      str = locale.number_format 123.456, 0
      assert.equal '123', str

      str = locale.number_format 123.456, 2
      assert.equal '123.46', str

      str = locale.number_format 98123.456, 2
      assert.equal '98,123.46', str

    test 'locale.formatPrice', ->
      str = locale.formatPrice 123, 0
      assert.equal '$123.00', str

      str = locale.formatPrice 123.4, 0
      assert.equal '$123.40', str

      str = locale.formatPrice 123.45, 0
      assert.equal '$123.45', str