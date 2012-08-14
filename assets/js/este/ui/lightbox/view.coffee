###
	@fileoverview este.ui.lightbox.View.
###

goog.provide 'este.ui.lightbox.View'
goog.provide 'este.ui.lightbox.View.create'

goog.require 'goog.ui.Component'
goog.require 'goog.events.KeyCodes'

class este.ui.lightbox.View extends goog.ui.Component

	###*
		@param {Element} currentAnchor
		@param {Array.<Element>} anchors
		@constructor
		@extends {goog.ui.Component}
	###
	constructor: (@currentAnchor, @anchors) ->
		super()

	###*
		Factory method.
		@param {Element} currentAnchor
		@param {Array.<Element>} anchors
	###
	@create = (currentAnchor, anchors) ->
		new View currentAnchor, anchors

	###*
		@type {Element}
	###
	currentAnchor: null

	###*
		@type {Array.<Element>}
	###
	anchors: null

	###*
		@inheritDoc
	###
	createDom: ->
		super()
		@getElement().className = 'este-ui-lightbox'
		@updateInternal()
		return

	###*
		@protected
	###
	updateInternal: ->
		imageSrc = @currentAnchor.href
		title = @currentAnchor.title
		firstDisabled = secondDisabled = ''
		currentAnchorIdx = goog.array.indexOf @anchors, @currentAnchor
		totalAnchorsCount = @anchors.length
		if @currentAnchor == @anchors[0]
			firstDisabled = ' este-ui-lightbox-disabled'
		if @currentAnchor == @anchors[totalAnchorsCount - 1]
			secondDisabled = ' este-ui-lightbox-disabled'
		@getElement().innerHTML = "
			<div class='este-ui-lightbox-background'></div>
			<div class='este-ui-lightbox-content'>
				<div class='este-ui-lightbox-image-wrapper'>
					<img class='este-ui-lightbox-image' src='#{imageSrc}'>
					<div class='este-ui-lightbox-title'>#{title}</div>
				</div>
			</div>
			<div class='este-ui-lightbox-sidebar'>
				<button class='este-ui-lightbox-previous#{firstDisabled}'>previous</button>
				<button class='este-ui-lightbox-next#{secondDisabled}'>next</button>
				<div class='este-ui-lightbox-numbers'>
					<span class='este-ui-lightbox-current'>#{currentAnchorIdx + 1}</span>/
					<span class='este-ui-lightbox-total'>#{totalAnchorsCount}</span>
				</div>
				<button class='este-ui-lightbox-close'>close</button>
			</div>"

	###*
		@inheritDoc
	###
	enterDocument: ->
		super()
		@getHandler().
			listen(@getElement(), 'click', @onClick).
			listen(@dom_.getDocument(), 'keydown', @onDocumentKeydown)
		return

	###*
		@param {goog.events.BrowserEvent} e
		@protected
	###
	onClick: (e) ->
		switch e.target.className
			when 'este-ui-lightbox-previous'
				@moveToNextImage false
			when 'este-ui-lightbox-next'
				@moveToNextImage true
			when 'este-ui-lightbox-close'
				@dispatchCloseEvent()

	###*
		@param {goog.events.BrowserEvent} e
		@protected
	###
	onDocumentKeydown: (e) ->
		switch e.keyCode
			when goog.events.KeyCodes.ESC
				@dispatchCloseEvent()
			when goog.events.KeyCodes.RIGHT, goog.events.KeyCodes.DOWN
				@moveToNextImage true
			when goog.events.KeyCodes.LEFT, goog.events.KeyCodes.UP
				@moveToNextImage false

	###*
		@param {boolean} next
		@protected
	###
	moveToNextImage: (next) ->
		@setNextCurrentAnchor next
		@updateInternal()

	###*
		@param {boolean} next
		@protected
	###
	setNextCurrentAnchor: (next) ->
		idx = goog.array.indexOf @anchors, @currentAnchor
		if next then idx++ else idx--
		anchor = @anchors[idx]
		return if !anchor
		@currentAnchor = anchor

	###*
		@protected
	###
	dispatchCloseEvent: ->
		@dispatchEvent 'close'