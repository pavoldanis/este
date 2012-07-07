###*
  @fileoverview Live reload. Your browsers don't need a refresh button.
###

do ->
  ws = new WebSocket 'ws://localhost:8000/'
  ws.onmessage = (e) ->
    switch e.data
      when 'page'
        window.location.reload true