###*
  @fileoverview Stay tuned for TodoMVC demo.
###

goog.provide 'app.start'

goog.require 'este.dev.Monitor.create'
goog.require 'app.users.Collection'
goog.require 'app.users.View'
goog.require 'este.History'

###*
  @param {Object} data
###
app.start = (data) ->

  users = new app.users.Collection data['listOfUsers']
  usersView = null
  
  history = new este.History
  goog.events.listen history, 'navigate', (e) ->
    switch e.token
      when 'users'
        usersView = new app.users.View users
        usersView.render()
      else 
        usersView?.dispose()
        
  history.setEnabled()

  setTimeout ->
    history.setToken 'users'
  , 1000

  if goog.DEBUG
    este.dev.Monitor.create()

  setInterval ->
    users.add 'unknown'
  , 2000

  goog.events.listen document, 'click', (e) ->
    switch e.target.className
      when 'enter'
        usersView.enterDocument()
      when 'exit'
        usersView.exitDocument()
  
# ensures the symbol will be visible after compiler renaming.
goog.exportSymbol 'app.start', app.start

