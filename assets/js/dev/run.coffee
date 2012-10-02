###*
  @fileoverview github.com/Steida/este.

  Features
    compile and watch CoffeeScript, Stylus, Soy, [project]-template.html
    update Google Closure deps.js
    run and watch *_test.coffee unit tests
    run simple NodeJS development server
    experimental support for TypeScript.

  Options
    -b, --build
      build and statically check source code
      [project].html will use one compiled script
      goog.DEBUG == false (code after 'if goog.DEBUG' will be stripped)

    -d, --debug
      just for build
      compiler flags: '--formatting=PRETTY_PRINT --debug=true'
      goog.DEBUG == true

    -v, --verbose
      if you are curious how much time each compilation task take

    -c, --ci
      continuous integration mode
      without http server and files watchers

    -o, --only
      compile just one namespace

  Usage
    'node run app'
      to start app development

    'node run app --build' or 'node run app -b'
      to test compiled version

    'node run app --build --debug'
      to test compiled version with debug mode enabled

    'node run este -b'
      special build mode only for este
      all provided namespaces are included into compilation

###

fs = require 'fs'
exec = require('child_process').exec
tests = require './tests'
http = require 'http'
pathModule = require 'path'
ws = require 'websocket.io'

# load and fix google closure base.js for node
do ->
  googBasePath = './assets/js/google-closure/closure/goog/base.js'
  googNodeBasePath = './assets/js/dev/nodebase.js'
  nodeBase = fs.readFileSync googBasePath, 'utf8'
  nodeBase = nodeBase.replace 'var goog = goog || {};', 'global.goog = global.goog || {};'
  nodeBase = nodeBase.replace 'goog.global = this;', 'goog.global = global;'
  fs.writeFileSync googNodeBasePath, nodeBase, 'utf8'
  require './nodebase'

coffeeForClosure = null
lazyRequireCoffeeForClosure = ->
  return if coffeeForClosure
  {coffeeForClosure} = require './../este/dev/coffeeforclosure'

options =
  project: null
  build: false
  debug: false
  verbose: false
  ci: false
  only: ''

socket = null
startTime = Date.now()
booting = true
watchOptions =
  # 10  -> cpu at 30%
  # 80  -> cpu at 10%
  # 100 -> cpu at 4%
  # todo: fix once nodejs fix watch on mac
  interval: 100
commandsRunning = false

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

Commands =
  projectTemplate: (callback) ->
    timestamp = Date.now().toString 36

    if options.build
      scripts = """
        <script src='/#{options.outputFilename}?build=#{timestamp}'></script>
      """
    else
      scripts = """
        <script src='/assets/js/dev/livereload.js'></script>
        <script src='/assets/js/google-closure/closure/goog/base.js'></script>
        <script src='/assets/js/deps.js'></script>
        <script src='/assets/js/#{options.project}/start.js'></script>
      """

    filePath = "./#{options.project}-template.html"

    if fs.existsSync filePath
      file = fs.readFileSync filePath, 'utf8'
      file = file.replace /###CLOSURESCRIPTS###/g, scripts
      file = file.replace /###BUILD_TIMESTAMP###/g, timestamp
      fs.writeFileSync "./#{options.project}.html", file, 'utf8'
    else
      console.log "#{filePath} does not exits."

    callback()

  removeJavascripts: (callback) ->
    for jsPath in getPaths 'assets', ['.js']
      fs.unlinkSync jsPath
    callback()

  coffeeScripts: "node assets/js/dev/node_modules/coffee-script/bin/coffee
    --compile
    --bare
    --output assets/js assets/js"

  coffeeForClosure: (callback, path) ->
    lazyRequireCoffeeForClosure()

    if path
      paths = [path]
    else
      paths = (path for path in getPaths 'assets', ['.js'])

    for path in paths
      if  path.indexOf('coffeeforclosure_test.js') == -1 &&
          path.indexOf('coffeeforclosure.js') == -1 &&
          fs.existsSync path
            file = fs.readFileSync path, 'utf8'
            file = coffeeForClosure file
            fs.writeFileSync path, file, 'utf8'

    callback()

  typeScripts: (callback, path) ->
    paths = (path for path in getPaths 'assets', ['.ts'])
    command = "node assets/js/dev/node_modules/typescript/bin/tsc
      #{paths.join ' '}"
    exec command, callback

  soyTemplates: (callback) ->
    soyPaths = getPaths 'assets', ['.soy']
    if !soyPaths.length
      callback()
      return
    command = getSoyCommand soyPaths
    exec command, callback

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

    # just for este development, require all namespaces for compilation
    # this is used when closure is updated, in we want to recompile
    # everything just for sure that everything works
    if options.only
      startjs = ["goog.provide('#{options.project}.start');"]
      startjs.push "goog.require('#{options.only}');"
      source = startjs.join '\n'
      fs.writeFileSync "./assets/js/#{options.project}/start.js", source, 'utf8'
    else if options.project == 'este'
      deps = tests.getDeps()
      namespaces = []
      for k, v of deps
        continue if k.indexOf('este.') != 0
        namespaces.push k
      startjs = ["goog.provide('este.start');"]
      for namespace in namespaces
        startjs.push "goog.require('#{namespace}');"
      source = startjs.join '\n'
      fs.writeFileSync "./assets/js/este/start.js", source, 'utf8'

    preservedClosureScripts = []

    if !options.debug
      for jsPath in getPaths 'assets', ['.js'], false, false
        source = fs.readFileSync jsPath, 'utf8'
        continue if source.indexOf('this.logger_.') == -1

        # preserve google closure scripts
        # we dont want to modify submodule
        if jsPath.indexOf('google-closure/') != -1
          preservedClosureScripts.push
            jsPath: jsPath
            source: source

        # replace all 'this.logger', but not '_this.logger'
        # fix for coffee _this alias
        source = source.replace /[^_](this\.logger_\.)/g, 'goog.DEBUG && this.logger_.'
        # replace all '_this.logger'
        source = source.replace /_this\.logger_\./g, 'goog.DEBUG && _this.logger_.'

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
      > #{options.outputFilename}"

    exec command, ->
      for script in preservedClosureScripts
        fs.writeFileSync script.jsPath, script.source, 'utf8'
      if options.project == 'este'
        fs.unlinkSync './assets/js/este/start.js'
      callback.apply null, arguments

  mochaTests: tests.run

  stylusStyles: (callback) ->
    paths = getPaths 'assets', ['.styl']
    command = "node assets/js/dev/node_modules/stylus/bin/stylus
      --compress #{paths.join ' '}"
    exec command, callback

start = (args) ->
  return if !setOptions args
  delete Commands.closureCompilation if !options.build

  runCommands Commands, (errors) ->
    if !options.ci
      startServer()
    if errors.length
      commands = (error.name for error in errors).join ', '
      console.log """
        Something's wrong with: #{commands}
        Fixit, then press cmd-s."""
      console.log error.stderr for error in errors
      # Signal error and exit (only if deploy, otherwise keep server running)
      if options.ci
        process.exit 1
    else
      console.log "Everything's fine, happy coding!",
        "#{(Date.now() - startTime) / 1000}s"
      # Signal ok and exit (only if deploy, otherwise keep server running)
      if options.ci
        process.exit 0
    booting = false

    if !options.ci
      watchPaths onPathChange

setOptions = (args) ->
  while args.length
    arg = args.shift()
    switch arg
      when '--debug', '-d'
        options.debug = true
      when '--verbose', '-v'
        options.verbose = true
      when '--build', '-b'
        options.build = true
      when '--ci', '-c'
        options.ci = true
      when '--only', '-o'
        options.only = args.shift()
      else
        options.project = arg

  path = "assets/js/#{options.project}"

  if !fs.existsSync path
    console.log "Project directory #{path} does not exists."
    return false

  if options.debug
    options.outputFilename = "assets/js/#{options.project}_dev.js"
  else
    options.outputFilename = "assets/js/#{options.project}.js"

  if options.build
    console.log 'Output filename: ' + options.outputFilename

  true

startServer = ->
  server = http.createServer (request, response) ->

    filePath = '.' + request.url
    filePath = "./#{options.project}.html" if filePath is './'
    filePath = filePath.split('?')[0] if filePath.indexOf('?') != -1

    if fs.existsSync filePath
      stats = fs.statSync filePath
      if stats.isDirectory()
        filePath = pathModule.join filePath, 'index.html'

    extname = pathModule.extname filePath

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
      else
        contentType = 'text/html'

    fs.exists filePath, (exists) ->
      if !exists
        response.writeHead 404
        response.end '404', 'utf-8'
        return

      fs.readFile filePath, (error, content) ->
        if error
          response.writeHead 500
          response.end '500', 'utf-8'
          return
        response.writeHead 200, 'Content-Type': contentType
        response.end content, 'utf-8'
    return

  wsServer = ws.attach server
  wsServer.on 'connection', (p_socket) ->
    socket = p_socket

  server.listen 8000

  console.log 'Server is listening on http://localhost:8000/'

getPaths = (directory, extensions, includeDirs, enforceClosure) ->
  paths = []
  files = fs.readdirSync directory
  for file in files
    path = directory + '/' + file
    # ignored directories
    continue if !enforceClosure && path.indexOf('google-closure/') > -1
    continue if path.indexOf('assets/js/dev') > -1
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
  paths = getPaths 'assets', ['.coffee', '.ts', '.styl', '.soy', '.html'], true
  paths.push "#{options.project}-template.html"
  paths.push 'assets/js/dev/run.coffee'
  paths.push 'assets/js/dev/mocks.coffee'
  paths.push 'assets/js/dev/deploy.coffee'
  paths.push 'assets/js/dev/tests.coffee'
  paths.push 'assets/js/dev/livereload.coffee'
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

  addBrowserLiveReloadCommand = (action) ->
    commands["reload browser"] = (callback) ->
      notifyClient action
      callback()

  switch pathModule.extname path
    when '.html'
      if path == "#{options.project}-template.html"
        commands['projectTemplate'] = Commands.projectTemplate
      addBrowserLiveReloadCommand 'page'

    when '.coffee'
      commands["coffeeScript: #{path}"] = "
        node assets/js/dev/node_modules/coffee-script/bin/coffee
          --compile --bare #{path}"

      commands["coffeeForClosure"] = (callback) ->
        Commands.coffeeForClosure callback, path.replace '.coffee', '.js'

      commands["closureDeps"] = Commands.closureDeps
      commands["mochaTests"] = Commands.mochaTests
      if options.build
        commands["closureCompilation"] = Commands.closureCompilation
      else
        addBrowserLiveReloadCommand 'page'

    when '.ts'
      commands["coffeeScript: #{path}"] = "
        node assets/js/dev/node_modules/typescript/bin/tsc
          #{path}"
      commands["closureDeps"] = Commands.closureDeps
      commands["mochaTests"] = Commands.mochaTests
      if options.build
        commands["closureCompilation"] = Commands.closureCompilation
      else
        addBrowserLiveReloadCommand 'page'

    when '.styl'
      commands["stylusStyle: #{path}"] = "
        node assets/js/dev/node_modules/stylus/bin/stylus
          --compress #{path}"
      addBrowserLiveReloadCommand 'styles'

    when '.soy'
      commands["soyTemplate: #{path}"] = getSoyCommand [path]
      commands["closureDeps"] = Commands.closureDeps
      if options.build
        commands["closureCompilation"] = Commands.closureCompilation
      addBrowserLiveReloadCommand 'page'

    else
      return

  clearScreen()
  return if commandsRunning
  runCommands commands

clearScreen = ->
  # todo: fix in windows
  # clear screen
  `process.stdout.write('\033[2J')`
  # set cursor position
  `process.stdout.write('\033[1;3H')`

runCommands = (commands, complete, errors = []) ->
  commandsRunning = true
  for name, command of commands
    break

  if !command
    commandsRunning = false
    if options.verbose && !booting
      console.log 'ready'
    complete errors if complete
    return

  if name == 'closureCompilation'
    console.log 'Compiling, please wait...'

  commandStartTime = Date.now()
  nextCommands = {}
  nextCommands[k] = v for k, v of commands when k != name

  onExec = (err, stdout, stderr) ->
    if name == 'closureCompilation'
      console.log 'Compilation finished.'

    isError = !!err
    # workaround: closure doesn't return err for warnings
    isError = true if !isError && name == 'closureCompilation' &&
      ~stderr?.indexOf ': WARNING -'

    if isError
      output = stderr
      if name == 'mochaTests'
        # we need stdout for console.log
        # remove screen clearing from stdout
        # todo: check windows
        stdout = stdout.trim()
        `stdout = stdout.replace('\033[2J', '')`
        `stdout = stdout.replace('\033[1;3H', '')`
        output = stderr + stdout
      if booting
        errors.push
          name: name
          command: command
          stderr: output
      else
        console.log output
        nextCommands = {}

    if booting || options.verbose
      console.log name + " in #{(Date.now() - commandStartTime) / 1000}s"
    runCommands nextCommands, complete, errors

  if typeof command == 'function'
    command onExec
  else
    exec command, onExec

  return

notifyClient = (message) ->
  return if !socket
  socket.send message

exports.start = start