###*
	@fileoverview Simple and very useful event delegation. You can listen what
	you want with custom filters. Much better solution than querySelectorAll
	based. Similar to Diego Perini bottom-up approach.
	@see ../demos/delegation.html
###
goog.provide 'este.events.Delegation'
goog.provide 'este.events.Delegation.create'

goog.require 'goog.events.EventTarget'
goog.require 'goog.events'
goog.require 'goog.dom'

class este.events.Delegation extends goog.events.EventTarget

	###*
		@param {Element} element
		@param {Array.<string>} eventTypes
		@constructor
		@extends {goog.events.EventTarget}
	###
	constructor: (@element, @eventTypes) ->
		super()
		@listenKey_ = goog.events.listen @element, @eventTypes, @

	###*
		@param {Element} element
		@param {Array.<string>} eventTypes
		@return {este.events.Delegation}
	###
	@create: (element, eventTypes, targetFilter, targetParentFilter) ->
		delegation = new este.events.Delegation element, eventTypes
		delegation.targetFilter = targetFilter
		delegation.targetParentFilter = targetParentFilter
		delegation

	###*
		@type {Element}
	###
	element: null

	###*
		@type {Array.<string>} eventTypes
	###
	eventTypes: null

	###*
		@param {Node} node
		@return {boolean}
	###
	targetFilter: (node) -> true

	###*
		@param {Node} node
		@return {boolean}
	###
	targetParentFilter: (node) -> true

	###*
		@type {?number}
		@private
	###
	listenKey_: null

	###*
		@param {goog.events.BrowserEvent} e
	###
	handleEvent: (e) ->
		return if !@matchFilter e
		@dispatchEvent e

	###*
		@param {goog.events.BrowserEvent} e
		@return {boolean} True for match
	###
	matchFilter: (e) ->
		targetMatched = false
		targetParentMatched = false
		element = e.target
		target = null
		while element
			if !targetMatched
				targetMatched = @targetFilter element
				target = element
			else if !targetParentMatched
				targetParentMatched = @targetParentFilter element
			else
				break
			element = element.parentNode
		if !targetMatched || !targetParentMatched
			return false
		e.target = target
		if e.type in ['mouseover', 'mouseout']
			return !e.relatedTarget || !goog.dom.contains target, e.relatedTarget
		true

	###*
		@inheritDoc
	###
	disposeInternal: ->
		super()
		goog.events.unlistenByKey @listenKey_
		delete @listenKey_
		return