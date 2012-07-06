###*
  @fileoverview Live reload. Just a concept.
  
  todo
    use websockets, consider socket.io
    postpone update of unfocused/hidden window
    live update styles and images
###

do ->
  setInterval ->
    xhr = new XMLHttpRequest()
    xhr.open 'GET', '/dev/live-reload', true
    xhr.onreadystatechange = ->
      return if @readyState != 4
      return if @status != 200
      return if @responseText != 'true'
      window.location.reload true
    xhr.send()
  , 100

