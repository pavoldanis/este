###*
  @fileoverview Live reload. Your browsers don't need a refresh button anymore.
###

do ->
  return if !window.WebSocket
  # cannot use goog.Uri, because livereload is loaded before closure library
  parser = document.createElement 'a'
  parser.href = window.location
  ws = new WebSocket "ws://#{parser.hostname}:#{parser.port}/"
  ws.onmessage = (e) ->
    switch e.data
      when 'page'
        window.location.reload true
      when 'styles'
        link.href = link.href for link in document.getElementsByTagName 'link'
    return
