###
  https://github.com/Steida/este

  todo
    deletion .css and .js ghost files after .styl and .coffee deletion
###

fs = require 'fs'
exec = require('child_process').exec
tests = require './tests'
http = require 'http'
pathModule = require 'path'

project = process.argv[2]

watchOptions =
  interval: 10

buildTemplate = ->
  exec "node assets/js/dev/build #{project} --html"

start = ->
  runServer()

  buildTemplate()
  fs.watchFile "#{project}-template.html", watchOptions, (curr, prev) ->
    return if curr.mtime <= prev.mtime
    buildTemplate()

  commands = (value for key, value of Commands)

  runCommands commands, (success) ->
    if success
      console.log 'ok'
    else
      console.log 'error'
    watchPaths onPathChange

  onPathChange = (path, dir) ->
    if dir
      watchPaths onPathChange
      return
    commands = null
    switch pathModule.extname path
      when '.coffee'
        commands = [
          "coffee --compile --bare #{path}"
          Commands.deps
          Commands.tests
        ]
      when '.styl'
        commands = [
          "stylus --compress #{path}"
        ]
      when '.soy'
        commands = [
          getSoyCommand path
        ]

    return if !commands
    clearScreen()
    runCommands commands
    return

clearScreen = ->
  # todo: fix in windows
  # clear screen
  `process.stdout.write('\033[2J')`
  # set cursor position
  `process.stdout.write('\033[1;3H')`

watchPaths = (callback) ->
  paths = getPaths 'assets'
  for path in paths
    continue if watchPaths['$' + path]
    watchPaths['$' + path] = true
    do (path) ->
      if path.indexOf('.') > -1
        fs.watchFile path, watchOptions, (curr, prev) ->
          # prevents changes on unrelated paths
          if curr.mtime > prev.mtime
            callback path, false
      else
        fs.watch path, watchOptions, ->
          callback path, true
  return

getPaths = (directory) ->
  paths = []
  files = fs.readdirSync directory
  for file in files
    path = directory + '/' + file
    continue if path.indexOf('js/google-closure') > -1
    continue if endsWith path, '.DS_Store'
    continue if endsWith path, '.js'
    paths.push path
    stats = fs.statSync path
    if stats.isDirectory()
      paths.push.apply paths, getPaths path
  paths

endsWith = (str, suffix) ->
  l = str.length - suffix.length
  l >= 0 && str.indexOf(suffix, l) == l
  
runCommandsAsyncTimer = null  
runCommands = (commands, callback) ->
  callback ?= ->
  if !commands.length
    callback true
    return
  command = commands[0]
  commands = commands.slice 1
  onExec = (err, stdout, stderr) ->
    if err
      console.log stderr
      callback false
      return
    runCommands commands, callback
  if typeof command == 'function'
    command onExec
  else if command.timeout
    clearTimeout runCommandsAsyncTimer
    runCommandsAsyncTimer = setTimeout ->
      exec command.command, onExec
    , command.timeout
  else
    exec command, onExec
  return

runServer = ->
  server = http.createServer (request, response) ->
    filePath = '.' + request.url
    filePath = "./#{project}.htm" if filePath is './'
    filePath = filePath.split('?')[0] if filePath.indexOf('?') != -1
    extname = pathModule.extname filePath
    contentType = 'text/html'
    
    switch extname
      when '.js'
        contentType = 'text/javascript'
      when '.css'
        contentType = 'text/css'
      when '.png'
        contentType = 'image/png'
      when '.gif'
        contentType = 'image/gif'
    
    fs.exists filePath, (exists) ->
      # because uri like /product/123 has to be handled by HTML5 pushState
      if !exists
        filePath = "./#{project}.html"

      fs.readFile filePath, (error, content) ->
        if error
          response.writeHead 500
          response.end '500', 'utf-8'
          return
        response.writeHead 200, 'Content-Type': contentType
        response.end content, 'utf-8'
      
  server.listen 8000

getSoyCommand = (path) ->
  "java -jar assets/js/dev/SoyToJsSrcCompiler.jar
    --shouldProvideRequireSoyNamespaces
    --shouldGenerateJsdoc
    --codeStyle concat
    --outputPathFormat {INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js
    #{path}"    

Commands =
  coffee: "coffee --compile --bare --output assets/js assets/js"
  deps:
    # depswriter.py deletes deps.js and restore it after several hundreds ms.
    # no-go for fast cmd-s, f5 development. 2s timeout seems to be fine.
    timeout: 2000
    command: "python assets/js/google-closure/closure/bin/build/depswriter.py
      --root_with_prefix=\"assets/js/google-closure ../../../google-closure\"
      --root_with_prefix=\"assets/js/dev ../../../dev\"
      --root_with_prefix=\"assets/js/este ../../../este\"
      --root_with_prefix=\"assets/js/#{project} ../../../#{project}\"
      > assets/js/deps.js"
  tests: tests.run
  stylus: "stylus --compress assets/css/"

# compile all soy templates onstart
soyPaths = (path for path in getPaths('assets') when endsWith(path, '.soy'))
for soyPath, i in soyPaths
  Commands['soy' + i] = [getSoyCommand(soyPath)]

start()

# 'stylus --compress --include assets/js/este/demos/css/* assets/css/*'
# 'stylus --compress assets/js/este/demos/css/*'