###*
	@fileoverview Simple and very useful event delegation. We can listen what we
	want and filter it with custom filters. Similar to Diego Perini bottom-up
	approach.
	@see ../demos/delegation.html
###
goog.provide 'este.events.Delegation'
goog.provide 'este.events.Delegation.create'

goog.require 'goog.dom'
goog.require 'goog.events'
goog.require 'goog.events.EventTarget'

class este.events.Delegation extends goog.events.EventTarget

	###*
		@param {Element} element
		@param {Array.<string>|string} eventTypes
		@constructor
		@extends {goog.events.EventTarget}
	###
	constructor: (@element, eventTypes) ->
		eventTypes = [eventTypes] if typeof eventTypes == 'string'
		@eventTypes = eventTypes
		goog.events.listen @element, @eventTypes, @
		super()

	###*
		@param {Element} element
		@param {Array.<string>|string} eventTypes
		@param {function(Node): boolean=} targetFilter
		@param {function(Node): boolean=} targetParentFilter
		@return {este.events.Delegation}
	###
	@create: (element, eventTypes, targetFilter, targetParentFilter) ->
		delegation = new este.events.Delegation element, eventTypes
		delegation.targetFilter = targetFilter if targetFilter
		delegation.targetParentFilter = targetParentFilter if targetParentFilter
		delegation

	###*
		@type {Element}
		@protected
	###
	element: null

	###*
		@type {Array.<string>} eventTypes
		@protected
	###
	eventTypes: null

	###*
		@type {function(Node): boolean}
	###
	targetFilter: (node) ->
		true

	###*
		@type {function(Node): boolean}
	###
	targetParentFilter: (node) ->
		true

	###*
		@type {?number}
		@private
	###
	listenKey_: null

	###*
		@param {goog.events.BrowserEvent} e
		@protected
	###
	handleEvent: (e) ->
		return if !@matchFilter e
		@dispatchEvent e

	###*
		@param {goog.events.BrowserEvent} e
		@return {boolean} True for match
		@protected
	###
	matchFilter: (e) ->
		targetMatched = false
		targetParentMatched = null
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

		return false if !targetMatched || targetParentMatched == false

		e.target = target
		if e.type in ['mouseover', 'mouseout']
			return !e.relatedTarget || !goog.dom.contains target, e.relatedTarget

		true

	###*
		@inheritDoc
	###
	disposeInternal: ->
		goog.events.unlisten @element, @eventTypes, @
		super()
		return