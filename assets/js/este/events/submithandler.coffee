###*
  @fileoverview Bubbled submit event.
###
goog.provide 'este.events.SubmitHandler'
goog.provide 'este.events.SubmitHandler.EventType'

goog.require 'este.Base'
goog.require 'este.dom'
goog.require 'goog.userAgent'

class este.events.SubmitHandler extends este.Base

  ###*
    @param {Element|Document=} node
    @constructor
    @extends {este.Base}
  ###
  constructor: (node = document) ->
    super()
    # ie doesn't bubble submit event, but focusin with lazy submit works.
    eventType = if goog.userAgent.IE && !goog.userAgent.isDocumentMode 9
      'focusin'
    else
      'submit'
    @on node, eventType, @

  ###*
    @enum {string}
  ###
  @EventType:
    SUBMIT: 'submit'

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  handleEvent: (e) ->
    if e.type == 'focusin'
      form = goog.dom.getAncestorByTagNameAndClass e.target, 'form'
      @on form, 'submit', @ if form
      return
    `var target = /** @type {Element} */ (e.target)`
    e.json = este.dom.serializeForm target
    @dispatchEvent e