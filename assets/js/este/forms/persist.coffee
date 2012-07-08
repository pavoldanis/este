###*
  @fileoverview Foo.

  todo
    dom path asi jako child index, nejrychlejsi a staci..
    expirace
    kezdej element listener.. dispose po re attachy
    // todo: reload, inner html, session/storage
    
    http://stackoverflow.com/a/266252/233902
    reset event
    submit for ie<9?
###
goog.provide 'este.forms.persist'

goog.require 'este.dom'
goog.require 'goog.events.FocusHandler'

goog.scope ->
  `var _ = este.forms`
  
  ###*
    @param {Element} element
  ###
  _.persist = (element) ->
    path = este.dom.getDomPathIndexes element

    onFieldTouched = (e) ->
      switch e.type
        when 'change'
          # save now
          foo = ''
        when 'focusin'
          # save now, start listening via inputhandler
          foo = ''

    # todo: dispose yet registereds
    focusHandler = new goog.events.FocusHandler element
    goog.events.listen focusHandler, 'focusin', onFieldTouched
    goog.events.listen element, 'change', onFieldTouched
    
    # el = este.dom.getElementByDomPathIndex path
    # ukladani..
    # nacist dom path elementu
    # jeli v kesi dom listener, disposni ho
    # zaregistruj bublajici focus
    # na kazdej field zaregistruj listener
    # je-li zaznam v localstorage nebo session, obnov
    # localstorage se musi expirovat

  return
