###*
  @fileoverview Live reload.
###

do ->
  ws = new WebSocket 'ws://localhost:8000/'
  ws.onmessage = (e) ->
    switch e.data
      when 'page'
        window.location.reload true