###*
  @fileoverview https://github.com/Steida/este.

  Features
    compile and watch CoffeeScript, Stylus, Soy, project-template.html
    update Google Closure deps.js
    run and watch *_test.coffee unit tests
    run simple NodeJS development server

  Options
    --debug     - shows time durations
    --deploy    - compile project-template.html with one script

  todo
    consider: delete .css and .js files on start
    group soy templates compilation into one task
###

fs = require 'fs'
exec = require('child_process').exec
tests = require './tests'
http = require 'http'
pathModule = require 'path'

project = process.argv[2]
debug = '--debug' in process.argv
deploy = '--deploy' in process.argv
startTime = Date.now()
booting = true

watchOptions =
  # 10  -> cpu at 30 %
  # 100 -> cpu at 4 %
  interval: 100

jsSubdirs = do ->
  for path in fs.readdirSync 'assets/js'
    continue if !fs.statSync("assets/js/#{path}").isDirectory()
    path

depsNamespaces = do ->
  namespaces = for dir in jsSubdirs
    "--root_with_prefix=\"assets/js/#{dir} ../../../#{dir}\" "
  namespaces.join ''

Commands =
  coffeeScripts: "coffee --compile --bare --output assets/js assets/js"
  closureDeps: "python assets/js/google-closure/closure/bin/build/depswriter.py
    #{depsNamespaces}
    > assets/js/deps.js"
  mochaTests: tests.run
  stylusStyles: (callback) ->
    paths = getPaths 'assets', ['.styl']
    command = "stylus --compress #{paths.join ' '}"
    exec command, callback

start = ->
  startServer()
  buildAndWatchProjectTemplate()
  addSoyTemplatesCompileCommands()
  
  runCommands Commands, (success, commandName, command) ->
    if success
      console.log "Everything's fine, happy coding!",
        "#{(Date.now() - startTime) / 1000}ms"
      booting = false
      watchPaths onPathChange
      return
    console.log "Error: #{commandName} -> #{command}"
    # todo: terminate process

  return

startServer = ->
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
      when '.jpg', '.jpeg'
        contentType = 'image/jpeg'
    
    fs.exists filePath, (exists) ->
      # because uri like /product/123 will be handled by HTML5 pushState
      if !exists
        filePath = "./#{project}.html"

      fs.readFile filePath, (error, content) ->
        if error
          response.writeHead 500
          response.end '500', 'utf-8'
          return
        response.writeHead 200, 'Content-Type': contentType
        response.end content, 'utf-8'
    return
      
  server.listen 8000
  console.log 'Server is listening at http://localhost:8000/'

buildAndWatchProjectTemplate = ->
  build = ->
    command = "node assets/js/dev/build #{project} --onlyhtml"
    command += ' --deploy' if deploy
    exec command
    console.log "#{project}-template.html compiled." 
  build()
  fs.watchFile "#{project}-template.html", watchOptions, (curr, prev) ->
    return if curr.mtime <= prev.mtime
    build()

addSoyTemplatesCompileCommands = ->
  soyPaths = getPaths 'assets', ['.soy']
  Commands['soyTemplate' + i] = getSoyCommand(soyPath) for soyPath, i in soyPaths

getPaths = (directory, extensions, includeDirs) ->
  paths = []
  files = fs.readdirSync directory
  for file in files
    path = directory + '/' + file
    # ignored directories
    continue if path.indexOf('/google-closure') > -1
    continue if path.indexOf('/node_modules') > -1
    if fs.statSync(path).isDirectory()
      paths.push path if includeDirs
      paths.push.apply paths, getPaths path, extensions, includeDirs
    else
      paths.push path if pathModule.extname(path) in extensions
  paths

getSoyCommand = (path) ->
  "java -jar assets/js/dev/SoyToJsSrcCompiler.jar
    --shouldProvideRequireSoyNamespaces
    --shouldGenerateJsdoc
    --codeStyle concat
    --outputPathFormat {INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js
    #{path}"

# slower watchFile, because http://nodejs.org/api/fs.html#fs_caveats
# todo: wait for fix
watchPaths = (callback) ->
  paths = getPaths 'assets', ['.coffee', '.styl', '.soy'], true
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

onPathChange = (path, dir) ->
  if dir
    watchPaths onPathChange
    return

  commands = {}
  switch pathModule.extname path
    when '.coffee'
      commands["coffeeScript: #{path}"] = "coffee --compile --bare #{path}"
      # tests first, they have to be as fast as possible
      commands["mochaTests"] = Commands.mochaTests
      # closure deps needs almost 2s
      commands["closureDeps"] = Commands.closureDeps
    when '.styl'
      commands["stylusStyle: #{path}"] = "stylus --compress #{path}"
    when '.soy'
      commands["soyTemplate: #{path}"] = getSoyCommand path
    else
      return

  clearScreen()
  runCommands commands

clearScreen = ->
  # todo: fix in windows
  # clear screen
  `process.stdout.write('\033[2J')`
  # set cursor position
  `process.stdout.write('\033[1;3H')`

runCommandsAsyncTimer = null

runCommands = (commands, onComplete) ->
  for name, command of commands
    break
  
  if !command
    onComplete true if onComplete
    return
  
  commandStartTime = Date.now()
  nextCommands = {}
  nextCommands[k] = v for k, v of commands when k != name
  
  onExec = (err, stdout, stderr) ->
    if err
      console.log stderr
      onComplete false, name, command if onComplete
      return
    if booting || debug
      console.log name, "#{(Date.now() - commandStartTime) / 1000}ms"
    runCommands nextCommands, onComplete
  
  if typeof command == 'function'
    command onExec
  else
    exec command, onExec
  return

start()