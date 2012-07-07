###*
  @fileoverview Live reload.
  
  todo
    postpone updates of unfocused/hidden window
    update styles and images too
###

do ->
  ws = new WebSocket 'ws://localhost:8000/'
  ws.onmessage = (e) ->
    switch e.data
      when 'page'
        window.location.reload true