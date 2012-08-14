###*
	@fileoverview
	@see ../demos/resizer.html
###
goog.provide 'este.ui.Resizer'

goog.require 'goog.ui.Component'

goog.require 'este.events.Delegation.create'
goog.require 'este.ui.resizer.Handles.create'

class este.ui.Resizer extends goog.ui.Component

	###*
		@param {Function}	delegationFactory
		@param {Function}	handlesFactory
		@constructor
		@extends {goog.ui.Component}
	###
	constructor: (@delegationFactory, @handlesFactory) ->
		super()

	###*
		@return {este.ui.Resizer}
	###
	@create: ->
		new Resizer este.events.Delegation.create, este.ui.resizer.Handles.create

	###*
		@enum {string}
	###
	@EventType:
		RESIZEEND: 'resizeend'

	###*
		@type {Function}
		@protected
	###
	delegationFactory: null

	###*
		@type {Function}
		@protected
	###
	handlesFactory: null

	###*
		@type {number}
	###
	minimalWidth: 5

	###*
		@type {number}
	###
	minimalHeight: 5

	###*
		@type {Element}
		@protected
	###
	activeElement: null

	###*
		@type {goog.math.Size}
		@protected
	###
	activeElementSize: null

	###*
		@param {Element} element
		@return {boolean}
	###
	targetFilter: (element) ->
		true

	###*
		@param {Element} element
		@return {boolean}
	###
	targetParentFilter: (element) ->
		true

	###*
		@type {este.events.Delegation}
		@protected
	###
	delegation: null

	###*
		@type {este.ui.resizer.Handles}
		@protected
	###
	handles: null

	###*
		@type {boolean}
		@protected
	###
	dragging: false

	###*
		@inheritDoc
	###
	enterDocument: ->
		super()
		events = ['mouseover', 'mouseout']
		@delegation = @delegationFactory @getElement(), events, @targetFilter, @targetParentFilter
		@getHandler().
			listen(@delegation, 'mouseover', @onDelegationMouseOver).
			listen(@delegation, 'mouseout', @onDelegationMouseOut)
		return

	###*
		@inheritDoc
	###
	exitDocument: ->
		super()
		@delegation.dispose()
		@handles.dispose() if @handles
		return

	###*
		@param {goog.events.BrowserEvent} e
		@protected
	###
	onDelegationMouseOver: (e) ->
		return if @dragging
		@handles.dispose() if @handles
		@handles = @handlesFactory()
		@handles.decorate e.target
		@getHandler().
			listen(@handles, 'mouseout', @onDelegationMouseOut).
			listen(@handles, 'start', @onDragStart).
			listen(@handles, 'drag', @onDrag).
			listen(@handles, 'end', @onDragEnd)

	###*
		@param {goog.events.BrowserEvent} e
		@protected
	###
	onDelegationMouseOut: (e) ->
		return if @dragging || @handles.isHandle e.relatedTarget
		@handles.dispose()

	###*
		@param {goog.events.BrowserEvent} e
		@protected
	###
	onDragStart: (e) ->
		`var el = /** @type {Element} */ (e.element)`
		@activeElementSize = goog.style.getContentBoxSize el
		@dragging = true

	###*
		@param {Object} e
		@protected
	###
	onDrag: (e) ->
		width = Math.max @minimalWidth, @activeElementSize.width + e.width
		height = Math.max @minimalHeight, @activeElementSize.height + e.height
		if e.element.tagName != 'IMG'
			e.element.style.width = width + 'px'
			e.element.style.height = height + 'px'
			return
		if e.vertical
			e.element.style.width = width + 'px'
			e.element.style.height = 'auto'
		else
			e.element.style.width = 'auto'
			e.element.style.height = height + 'px'

	###*
		@param {Object} e
		@protected
	###
	onDragEnd: (e) ->
		@dragging = false
		@handles.dispose() if e.close
		@dispatchEvent
			type: Resizer.EventType.RESIZEEND
			element: e.element