###*
  @fileoverview Live reload. Your browsers don't need a refresh button.
###

do ->
  ws = new WebSocket 'ws://localhost:8000/'
  ws.onmessage = (e) ->
    switch e.data
      when 'page'
        window.location.reload true
      when 'styles'
        link.href = link.href for link in document.getElementsByTagName 'link'
    return
