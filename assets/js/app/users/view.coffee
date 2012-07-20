###*
  @fileoverview User view.
###
goog.provide 'app.users.View'

goog.require 'goog.ui.Component'
goog.require 'app.users.templates'

###*
  @param {app.users.Collection} users
  @constructor
  @extends {goog.ui.Component}
###
app.users.View = (@users) ->
  goog.base @
  return

goog.inherits app.users.View, goog.ui.Component
  
goog.scope ->
  `var _ = app.users.View`

  ###*
    @type {app.users.Collection}
    @protected
  ###
  _::users

  _::enterDocument = ->
    goog.base @, 'enterDocument'
    @getHandler().
      listen(@users, 'change', @onUsersChange)
    @update()
    return

  _::onUsersChange = (e) ->
    @update()

  ###*
    @protected
  ###
  _::update = ->
    @getElement().innerHTML = app.users.templates.list
      users: @users.toJson()

  return
