###*
  @fileoverview Forms persister. Persist form fields state into localStorage
  or session.

  todo
    session only
    use tag, id, class, name, type.. based dom path
    ensure clean after innerHTML
    expiration
    http://stackoverflow.com/a/266252/233902
    reset event (does bubble?)
    change for ie<9? (does bubble?)
###

goog.provide 'este.ui.FormsPersister'
goog.provide 'este.ui.FormsPersister.create'

goog.require 'goog.dom.forms'
goog.require 'este.dom'
goog.require 'goog.events.FocusHandler'
goog.require 'goog.events.InputHandler'
goog.require 'este.storage.create'

###*
  @param {boolean=} onlySession
  @constructor
  @extends {goog.ui.Component}
###
este.ui.FormsPersister = (@onlySession = false) ->
  goog.base @
  @storage = este.storage.create 'ui:formspersister'
  return

goog.inherits este.ui.FormsPersister, goog.ui.Component

goog.scope ->
  `var _ = este.ui.FormsPersister`
  `var forms = goog.dom.forms`

  ###*
    @param {Element} element
    @param {boolean=} onlySession
    @return {este.ui.FormsPersister}
  ###
  _.create = (element, onlySession) ->
    persist = new este.ui.FormsPersister onlySession
    persist.decorate element
    persist

  ###*
    @type {boolean}
    @protected
  ###
  _::onlySession

  ###*
    @type {goog.storage.Storage}
    @protected
  ###
  _::storage

  ###*
    @type {goog.events.FocusHandler}
    @protected
  ###
  _::focusHandler

  ###*
    @override
  ###
  _::decorateInternal = (element) ->
    goog.base @, 'decorateInternal', element
    path = @getElementDomPathIndexes()
    storage = @storage.get path.join()
    return if !storage
    `storage = /** @type {Object} */ (storage)`
    @retrieve storage
    return

  ###*
    @param {Object} data
    @protected
  ###
  _::retrieve = (data) ->
    for formPath, fields of data
      form = este.dom.getElementByDomPathIndex formPath.split ','
      for name, value of fields
        field = form.querySelector "[name='#{name}']"
        switch field.type
          when 'radio'
            for el in field.form.elements when el.name == field.name
              forms.setValue el, el.value == value  
          when 'checkbox'
            for el in field.form.elements when el.name == field.name
              forms.setValue el, el.value == value
          else
            forms.setValue field, value
    return

  ###*
    @override
  ###
  _::enterDocument = ->
    goog.base @, 'enterDocument'
    @focusHandler = new goog.events.FocusHandler @getElement()
    @getHandler().
      listen(@focusHandler, 'focusin', @onFocusin).
      listen(@getElement(), 'change', @onChange)
    return

  ###*
    @override
  ###
  _::exitDocument = ->
    @focusHandler.dispose()
    goog.base @, 'exitDocument'
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  _::onFocusin = (e) ->
    `var target = /** @type {Element} */ (e.target)`
    return if !(target.tagName in ['INPUT', 'TEXTAREA'])
    @registerInputHander target

  ###*
    @param {Element} field
    @protected
  ###
  _::registerInputHander = (field) ->
    handler = new goog.events.InputHandler field
    @getHandler().listen handler, 'input', @onFieldInput
    @getHandler().listenOnce field, 'blur', (e) ->
      handler.dispose()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  _::onFieldInput = (e) ->
    `var target = /** @type {Element} */ (e.target)`
    @storeField target

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  _::onChange = (e) ->
    `var target = /** @type {Element} */ (e.target)`
    @storeField target

  ###*
    @param {Element} field
    @protected
  ###
  _::storeField = (field) ->
    formDomPath = este.dom.getDomPathIndexes field.form
    name = field.name
    value = @getFieldValue field
    @store formDomPath, name, value

  ###*
    @param {Array.<number>} formDomPath
    @param {string} name
    @param {string|Array.<string>} value
  ###
  _::store = (formDomPath, name, value) ->
    path = @getElementDomPathIndexes()
    key = path.join()
    # todo: refactor
    storage = @storage.get key
    storage = {} if !storage
    formStorage = storage[formDomPath] ?= {}
    formStorage[name] = value
    @storage.set key, storage

  ###*
    @return {Array.<number>}
    @protected
  ###
  _::getElementDomPathIndexes = ->
    este.dom.getDomPathIndexes @getElement()

  ###*
    @param {Element} field
    @return {string|Array.<string>}
    @protected
  ###
  _::getFieldValue = (field) ->
    if field.type == 'checkbox'
      values = []
      for el in field.form.elements when el.name == field.name
        value = forms.getValue el
        values.push value if value?
      return values
    forms.getValue field

  ###*
    @override
  ###
  _::disposeInternal = ->
    goog.base @, 'disposeInternal'
    return

  return