###*
  @fileoverview Just a very simple grid component for demonstration of
  templates, este.Collection events, and este.ui.Component subclassing.
###
goog.provide 'este.demos.Grid'

goog.require 'este.demos.grid.templates'
goog.require 'este.ui.Component'

class este.demos.Grid extends este.ui.Component

  ###*
    @param {Object.<string, string>} columns
    @param {este.Collection} rows
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (@columns, @rows) ->
    super()

  ###*
    @type {Object.<string, string>}
    @protected
  ###
  columns: null

  ###*
    @type {este.Collection}
    @protected
  ###
  rows: null

  ###*
    @type {este.Model}
    @protected
  ###
  editedRow: null

  ###*
    @inheritDoc
  ###
  canDecorate: (el) ->
    false

  ###*
    @inheritDoc
  ###
  createDom: ->
    super()
    @renderRows()
    return

  ###*
    @inheritDoc
  ###
  enterDocument: ->
    super()
    @on @rows, 'update', @onRowsUpdate
    @on 'tr', 'dblclick', @onTrDblclick
    return

  ###*
    @param {este.Model.Event} e
    @protected
  ###
  onRowsUpdate: (e) ->
    @renderRows()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTrDblclick: (e) ->
    id = e.target.getAttribute 'data-clientid'
    row = @rows.findById Number id
    row.set 'edited', true
    @editedRow.set 'edited', false if @editedRow
    @editedRow = row

  ###*
    @protected
  ###
  renderRows: ->
    rows = @rows.toJson()
    html = este.demos.grid.templates.table
      columns: (value for key, value of @columns)
      rows: rows
    @getElement().innerHTML = html