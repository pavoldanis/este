###*
  @fileoverview https://github.com/Steida/este.

  Features
    compile and watch CoffeeScript, Stylus, Soy, [project]-template.html
    update Google Closure deps.js
    run and watch [*]_test.coffee unit tests
    run simple NodeJS development server

  Workflow
    'node run app'
      to start app development
    
    'node run app --deploy'
      build scripts with closure compiler
      [project].html will use one compiled script
      goog.DEBUG == false (code using that will be stripped)

    'node run app --deploy --debug'
      use closure compiler flags: '--formatting=PRETTY_PRINT --debug=true'
      goog.DEBUG == true

    'node run app --verbose'
      if you are curious how much time each compilation took

  Todo
    fix too much cmd-s's errors
    consider: delete .css and .js files on start
    strip asserts and throws too
    CI
###

fs = require 'fs'
exec = require('child_process').exec
tests = require './tests'
http = require 'http'
pathModule = require 'path'

options =
  project: null
  verbose: false
  debug: false
  deploy: false

startTime = Date.now()
booting = true
watchOptions =
  # 10  -> cpu at 30%
  # 80  -> cpu at 10%
  # 100 -> cpu at 4%
  # todo: fix once nodejs fix watch on mac
  interval: 100

jsSubdirs = do ->
  for path in fs.readdirSync 'assets/js'
    continue if !fs.statSync("assets/js/#{path}").isDirectory()
    path

depsNamespaces = do ->
  namespaces = for dir in jsSubdirs
    "--root_with_prefix=\"assets/js/#{dir} ../../../#{dir}\" "
  namespaces.join ''

buildNamespaces = do ->
  namespaces = for dir in jsSubdirs
    "--root=assets/js/#{dir} "
  namespaces.join ''

###*
  Commands for watchables.
###

Commands =
  projectTemplate: (callback) ->
    try
      timestamp = Date.now().toString 36
      if options.deploy
        scripts = """
          <script src='/assets/js/#{options.project}.js?build=#{timestamp}'></script>
        """
      else
        scripts = """
          <script src='/assets/js/google-closure/closure/goog/base.js'></script>
          <script src='/assets/js/deps.js'></script>
          <script src='/assets/js/#{options.project}/start.js'></script>
        """
      file = fs.readFileSync "./#{options.project}-template.html", 'utf8'
      file = file.replace /###CLOSURESCRIPTS###/g, scripts
      file = file.replace /###BUILD_TIMESTAMP###/g, timestamp
      # todo: what's that?
      file = file.replace /###CONFIG_START###/g, ''
      file = file.replace /###CONFIG_END###/g, ''
      fs.writeFileSync "./#{options.project}.html", file, 'utf8'
    
    catch e
      callback true, null, e.toString

    finally
      callback()

  coffeeScripts: "coffee --compile --bare --output assets/js assets/js"
  
  closureDeps: "python assets/js/google-closure/closure/bin/build/depswriter.py
    #{depsNamespaces}
    > assets/js/deps.js"
  
  closureCompilation: (callback) ->
    if options.debug
      flags = '--formatting=PRETTY_PRINT --debug=true'
    else
      flags = '--define=goog.DEBUG=false'
    
    flagsText = ''
    flagsText += "--compiler_flags=\"#{flag}\" " for flag in flags.split ' '

    preservedClosureScripts = []
    if !options.debug
      for jsPath in getPaths 'assets', ['.js'], false, true
        source = fs.readFileSync jsPath, 'utf8'
        continue if source.indexOf('this.logger_.') == -1
        # preserve google closure scripts
        # we dont want to modify submodule
        if jsPath.indexOf('google-closure/') != -1
          preservedClosureScripts.push jsPath: jsPath, source: source
        source = source.replace /this\.logger_\./g, 'goog.DEBUG && this.logger_.'
        fs.writeFileSync jsPath, source, 'utf8'
    
    command = "python assets/js/google-closure/closure/bin/build/closurebuilder.py
      #{buildNamespaces}
      --namespace=\"#{options.project}.start\"
      --output_mode=compiled
      --compiler_jar=assets/js/dev/compiler.jar
      --compiler_flags=\"--compilation_level=ADVANCED_OPTIMIZATIONS\"
      --compiler_flags=\"--jscomp_warning=visibility\"
      --compiler_flags=\"--warning_level=VERBOSE\"
      --compiler_flags=\"--output_wrapper=(function(){%output%})();\"
      --compiler_flags=\"--js=assets/js/deps.js\"
      #{flagsText}
      > assets/js/#{options.project}.js"

    exec command, ->
      for script in preservedClosureScripts
        fs.writeFileSync script.jsPath, script.source, 'utf8' 
      callback.apply null, arguments

  mochaTests: tests.run

  stylusStyles: (callback) ->
    paths = getPaths 'assets', ['.styl']
    command = "stylus --compress #{paths.join ' '}"
    exec command, callback

  soyTemplates: (callback) ->
    soyPaths = getPaths 'assets', ['.soy']
    command = getSoyCommand soyPaths
    exec command, callback

start = (args) ->
  setOptions args
  delete Commands.closureCompilation if !options.deploy
  
  runCommands Commands, (errors) ->
    startServer()
    if errors.length
      commands = (error.name for error in errors).join ', '
      console.log """
        Something's wrong with: #{commands}
        Fixit, then press cmd-s."""
      console.log error.stderr for error in errors
    else
      console.log "Everything's fine, happy coding!",
        "#{(Date.now() - startTime) / 1000}ms"
    booting = false
    watchPaths onPathChange

setOptions = (args) ->
  while args.length
    arg = args.shift()
    switch arg
      when '--debug'
        options.debug = true
      when '--verbose'
        options.verbose = true
      when '--deploy'
        options.deploy = true
      else
        options.project = arg
  return

startServer = ->
  server = http.createServer (request, response) ->
    filePath = '.' + request.url
    filePath = "./#{options.project}.htm" if filePath is './'
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
        filePath = "./#{options.project}.html"

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

getPaths = (directory, extensions, includeDirs, enforceClosure) ->
  paths = []
  files = fs.readdirSync directory
  for file in files
    path = directory + '/' + file
    # ignored directories
    continue if !enforceClosure && path.indexOf('google-closure/') > -1
    continue if path.indexOf('/node_modules') > -1
    if fs.statSync(path).isDirectory()
      paths.push path if includeDirs
      paths.push.apply paths, getPaths path, extensions, includeDirs, enforceClosure
    else
      paths.push path if pathModule.extname(path) in extensions
  paths

getSoyCommand = (paths) ->
  "java -jar assets/js/dev/SoyToJsSrcCompiler.jar
    --shouldProvideRequireSoyNamespaces
    --shouldGenerateJsdoc
    --codeStyle concat
    --outputPathFormat {INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js
    #{paths.join ' '}"

# slower watchFile, because http://nodejs.org/api/fs.html#fs_caveats
# todo: wait for fix
watchPaths = (callback) ->
  paths = getPaths 'assets', ['.coffee', '.styl', '.soy'], true
  paths.push "#{options.project}-template.html"
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
    when '.html'
      if path == "#{options.project}-template.html"
        commands['projectTemplate'] = Commands.projectTemplate
    when '.coffee'
      commands["coffeeScript: #{path}"] = "coffee --compile --bare #{path}"
      # tests first, they have to be as fast as possible
      commands["mochaTests"] = Commands.mochaTests
      commands["closureDeps"] = Commands.closureDeps
      if options.deploy
        commands["closureCompilation"] = Commands.closureCompilation
    when '.styl'
      commands["stylusStyle: #{path}"] = "stylus --compress #{path}"
    when '.soy'
      commands["soyTemplate: #{path}"] = getSoyCommand [path]
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

runCommands = (commands, onComplete, errors = []) ->
  for name, command of commands
    break
  
  if !command
    onComplete errors if onComplete
    return

  if name == 'closureCompilation'
    console.log 'Compiling scripts, wait pls...'
  
  commandStartTime = Date.now()
  nextCommands = {}
  nextCommands[k] = v for k, v of commands when k != name

  onExec = (err, stdout, stderr) ->
    if name == 'closureCompilation'
      console.log 'done'

    isError = !!err
    # workaround: closure doesn't return err for warnings
    isError = true if !isError && name == 'closureCompilation' &&
      ~stderr?.indexOf ': WARNING -'

    if isError
      if booting
        errors.push
          name: name
          command: command
          stderr: stderr
      else
        console.log stderr
        nextCommands = {}

    if booting || options.verbose
      console.log name, "#{(Date.now() - commandStartTime) / 1000}ms"
    runCommands nextCommands, onComplete, errors
  
  if typeof command == 'function'
    command onExec
  else
    exec command, onExec

  return

exports.start = start