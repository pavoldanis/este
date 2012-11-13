###*
  @fileoverview One script to automatically compile and watch CoffeeScript,
  Stylus, and Soy templates. Run fast unit test on source files change. No need
  to take care about ordered list of project files with Closure dependency
  system. LiveReload supported.

  Todo
    rewrite this (legacy) mess into good code in Este style
###

fs = require 'fs'
exec = require('child_process').exec
tests = require './tests'
http = require 'http'
pathModule = require 'path'
ws = require 'websocket.io'
esprima = require 'esprima'
wrench = require 'wrench'

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
  buildOptions: []
  buildAll: false
  debug: false
  verbose: false
  ci: false
  only: ''
  port: 8000
  errorBeep: false
  locale: ''

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
    for jsPath in getPaths 'assets/js', ['.js']
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
      paths = (path for path in getPaths 'assets/js', ['.js'])

    for path in paths
      # coffeeforclosure source files has to be ignored
      if  path.indexOf('coffeeforclosure_test.js') == -1 &&
          path.indexOf('coffeeforclosure.js') == -1 &&
          fs.existsSync path
            file = fs.readFileSync path, 'utf8'
            file = coffeeForClosure file
            fs.writeFileSync path, file, 'utf8'

    callback()

  # typeScripts: (callback, path) ->
  #   paths = (path for path in getPaths 'assets', ['.ts'])
  #   command = "node assets/js/dev/node_modules/typescript/bin/tsc
  #     #{paths.join ' '}"
  #   exec command, callback

  soyTemplates: (callback) ->
    soyPaths = getPaths 'assets/js', ['.soy']
    if !soyPaths.length
      callback()
      return
    command = getSoyCommand soyPaths
    exec command, callback

  closureDeps: "python assets/js/google-closure/closure/bin/build/depswriter.py
    #{depsNamespaces}
    > assets/js/deps.js"

  closureCompilation: (callback) ->
    if fs.existsSync 'assets/js-build'
      wrench.rmdirSyncRecursive 'assets/js-build'
    wrench.copyDirSyncRecursive 'assets/js', 'assets/js-build'

    if options.debug
      flags = '--formatting=PRETTY_PRINT --debug=true'
    else
      flags = '--define=goog.DEBUG=false'

    flagsText = ''
    for flag in flags.split ' '
      flagsText += "--compiler_flags=\"#{flag}\" "

    for flag in options.buildOptions
      flagsText += "--compiler_flags=\"#{flag}\" "

    innerFn = ->
      # buildAll override start.js to require all namespaces in project.
      # Useful if we want to compile all namespaces, not just required.
      if options.buildAll
        deps = tests.getDeps()
        namespaces = []
        for k, v of deps
          continue if k.indexOf("#{options.project}.") != 0
          # prevents circular dependency issues
          continue if k == "#{options.project}.start"
          namespaces.push k
        startjs = ["goog.provide('#{options.project}.start');"]
        for namespace in namespaces
          startjs.push "goog.require('#{namespace}');"
        source = startjs.join '\n'
        fs.writeFileSync "./assets/js-build/#{options.project}/start.js", source, 'utf8'

      if options.only
        startjs = ["goog.provide('#{options.project}.start');"]
        startjs.push "goog.require('#{options.only}');"
        source = startjs.join '\n'
        fs.writeFileSync "./assets/js/#{options.project}/start.js", source, 'utf8'

      # strip loggers from compiled code
      if !options.debug
        for jsPath in getPaths 'assets/js-build', ['.js'], false, true
          source = fs.readFileSync jsPath, 'utf8'
          continue if source.indexOf('this.logger_.') == -1
          source = source.
            replace(/[^_](this\.logger_\.)/g, 'goog.DEBUG && this.logger_.').
            replace(/_this\.logger_\./g, 'goog.DEBUG && _this.logger_.')
          fs.writeFileSync jsPath, source, 'utf8'

      buildNamespaces = do ->
        namespaces = for dir in jsSubdirs
          "--root=assets/js-build/#{dir} "
        namespaces.join ''

      # to allow project name like este/demos/app/todomvc
      namespace = options.project.replace /\//g, '.'

      command = "python assets/js/google-closure/closure/bin/build/closurebuilder.py
        #{buildNamespaces}
        --namespace=\"#{namespace}.start\"
        --output_mode=compiled
        --compiler_jar=assets/js/dev/compiler.jar
        --compiler_flags=\"--compilation_level=ADVANCED_OPTIMIZATIONS\"
        --compiler_flags=\"--warning_level=VERBOSE\"
        --compiler_flags=\"--jscomp_warning=accessControls\"
        --compiler_flags=\"--jscomp_warning=ambiguousFunctionDecl\"
        --compiler_flags=\"--jscomp_warning=checkDebuggerStatement\"
        --compiler_flags=\"--jscomp_warning=checkRegExp\"
        --compiler_flags=\"--jscomp_warning=checkTypes\"
        --compiler_flags=\"--jscomp_warning=checkVars\"
        --compiler_flags=\"--jscomp_warning=const\"
        --compiler_flags=\"--jscomp_warning=constantProperty\"
        --compiler_flags=\"--jscomp_warning=deprecated\"
        --compiler_flags=\"--jscomp_warning=duplicate\"
        --compiler_flags=\"--jscomp_warning=externsValidation\"
        --compiler_flags=\"--jscomp_warning=fileoverviewTags\"
        --compiler_flags=\"--jscomp_warning=globalThis\"
        --compiler_flags=\"--jscomp_warning=internetExplorerChecks\"
        --compiler_flags=\"--jscomp_warning=invalidCasts\"
        --compiler_flags=\"--jscomp_warning=missingProperties\"
        --compiler_flags=\"--jscomp_warning=nonStandardJsDocs\"
        --compiler_flags=\"--jscomp_warning=strictModuleDepCheck\"
        --compiler_flags=\"--jscomp_warning=undefinedNames\"
        --compiler_flags=\"--jscomp_warning=undefinedVars\"
        --compiler_flags=\"--jscomp_warning=unknownDefines\"
        --compiler_flags=\"--jscomp_warning=uselessCode\"
        --compiler_flags=\"--jscomp_warning=visibility\"
        --compiler_flags=\"--output_wrapper=(function(){%output%})();\"
        --compiler_flags=\"--js=assets/js-build/deps.js\"
        #{flagsText}
        > #{options.outputFilename}"

      exec command, ->
        wrench.rmdirSyncRecursive 'assets/js-build'
        callback.apply null, arguments

    if options.locale
      flagsText += "--compiler_flags=\"--define=goog.LOCALE='#{options.locale}'\" "
      insertMessages innerFn
    else
      innerFn()

  mochaTests: tests.run

  stylusStyles: (callback) ->
    paths = getPaths 'assets/css', ['.styl']
    command = "node assets/js/dev/node_modules/stylus/bin/stylus
      --compress #{paths.join ' '}"
    exec command, callback

start = (args) ->
  return if !setOptions args
  if !options.build && !options.buildAll
    delete Commands.closureCompilation

  runCommands Commands, (errors) ->
    if !options.ci
      startServer()
    if errors.length
      commands = (error.name for error in errors).join ', '
      console.log """
        Something's wrong with: #{commands}
        Fix it, then press cmd/ctrl-s."""
      console.log error.stderr for error in errors
      # Signal error and exit (only if deploy, otherwise keep server running)
      if options.ci
        process.exit 1
    else
      console.log "Everything's fine, happy coding.",
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
        options.buildOptions = args.splice 0, args.length

      when '--buildall', '-ba'
        options.buildAll = true

      when '--continuousintegration', '-ci'
        options.ci = true

      when '--only', '-o'
        options.only = args.shift()

      when '--port', '-p'
        options.port = args.shift()

      when '--errorbeep', '-eb'
        options.errorBeep = true

      when '--extractmessages', '-em'
        languages = args.splice 0, args.length
        extractMessages languages
        return false

      when '--help', '-h'
        console.log """

          Options:
            --build, -b
              Compile everything, run tests, build project.
              Update [project].html to use just one compiled script.
              Set goog.DEBUG flag to false.
              Start watching all source files, recompile them on change.

              Example how to set compiler_flags:
                node run app -b
                  --define=goog.DEBUG=true
                  --define=goog.LOCALE=\'cs\'

              Example how to use localization:
                node run app -b en
                  set goog.LOCALE to 'en'
                  insert messages from assets/messages/[project]/[LOCALE].json
                  compile to assets/js/[project]_[en].js

            --debug, -d
              Same as build, but with these compiler flags:
                '--formatting=PRETTY_PRINT --debug=true'
              Set goog.DEBUG flag to false.
              Compiler output will be much readable.

              Example:
                node run app -d -b (note that -d is before -b)

            --verbose, -v
              To show some time stats.

            --continuousintegration, -ci
              Continuous integration mode. Without http server and files watchers.

            --port, -p
              To override default http://localhost:8000/ port.

            --buildall, -ba
              Build and statically check all namespaces in project. Useful for
              debugging, after closure update, etc.

            --errorbeep, -eb
              Friendly beep on error.

            --extractmessages, -em
              Extract messages from source code and generate dictionaries in
              assets/messages/project directory. Messages are defined with
              goog.getMsg method.

              Example
                node run app -em en de

            --help, -h
              To show this help.

        """
        return false

      else
        options.project = arg

  path = "assets/js/#{options.project}"

  if !fs.existsSync path
    console.log "Project directory #{path} does not exists."

  if options.buildOptions[0]?.indexOf('--') != 0
    options.locale = options.buildOptions[0]
    options.buildOptions.shift()

  outputFilename = "assets/js/#{options.project}"

  if options.locale
    outputFilename += "_#{options.locale}"

  if options.debug
    # I remember some bizare bug related to _debug suffix.
    outputFilename += '_dev.js'
  else
    outputFilename += '.js'

  options.outputFilename = outputFilename

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

  server.listen options.port

  console.log "Server is listening on http://localhost:#{options.port}/"

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
    --shouldGenerateGoogMsgDefs
    --bidiGlobalDir 1
    --shouldGenerateJsdoc
    --codeStyle concat
    --outputPathFormat {INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js
    #{paths.join ' '}"

# slower watchFile, because http://nodejs.org/api/fs.html#fs_caveats
# todo: wait for fix
watchPaths = (callback) ->
  paths = getPaths 'assets/js', ['.coffee', '.ts', '.styl', '.soy', '.html'], true
  stylusStyles = getPaths 'assets/css', ['.styl'], true
  paths.push.apply paths, stylusStyles
  paths.push "#{options.project}-template.html"
  paths.push 'assets/js/dev/livereload.coffee'
  paths.push 'assets/js/dev/mocks.coffee'
  paths.push 'assets/js/dev/run.coffee'
  paths.push 'assets/js/dev/tests.coffee'
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
      if options.build || options.buildAll
        commands["closureCompilation"] = Commands.closureCompilation
      else
        addBrowserLiveReloadCommand 'page'

    # when '.ts'
    #   commands["coffeeScript: #{path}"] = "
    #     node assets/js/dev/node_modules/typescript/bin/tsc
    #       #{path}"
    #   commands["closureDeps"] = Commands.closureDeps
    #   commands["mochaTests"] = Commands.mochaTests
    #   if options.build || options.buildAll
    #     commands["closureCompilation"] = Commands.closureCompilation
    #   else
    #     addBrowserLiveReloadCommand 'page'

    when '.styl'
      commands["stylusStyle: #{path}"] = "
        node assets/js/dev/node_modules/stylus/bin/stylus
          --compress #{path}"
      addBrowserLiveReloadCommand 'styles'

    when '.soy'
      commands["soyTemplate: #{path}"] = getSoyCommand [path]
      commands["closureDeps"] = Commands.closureDeps
      if options.build || options.buildAll
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
    # This 'console.log arguments' is for debugging windows-only error:
    #   [Error: Command failed: ] killed: false...
    # console.log arguments
    if name == 'closureCompilation'
      console.log 'Compilation finished.'

    isError = !!err || stderr
    # workaround for Google Closure Compiler, all output is returned as stderr
    # consider: 'JavaScript compilation succeeded' message
    if name == 'closureCompilation'
      isError = isClosureCompilationError stderr

    if isError
      output = stderr

      # we need stdout for console.log if some test fail
      if name == 'mochaTests'
        stdout = stdout.trim()
        # remove screen clearing from stdout
        `stdout = stdout.replace('\033[2J', '')`
        `stdout = stdout.replace('\033[1;3H', '')`
        output = stderr + stdout

      if booting
        errors.push
          name: name
          command: command
          stderr: output
      else
        if options.errorBeep
          console.log output + '\x07'
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

extractMessages = (languages) ->
  # ensure paths and files are created
  messagesPath = 'assets/messages'
  fs.mkdir messagesPath if !fs.existsSync messagesPath
  projectPath = "#{messagesPath}/#{options.project}"
  fs.mkdir projectPath if !fs.existsSync projectPath
  for language in languages
    languagePath = "#{projectPath}/#{language}.json"
    fs.writeFileSync languagePath, '{}', 'utf8' if !fs.existsSync languagePath

  getProjectPaths 'js', (scripts) ->
    # create dictionary from extracted messages
    dictionary = {}
    for script in scripts
      source = fs.readFileSync script, 'utf8'
      continue if source.indexOf('goog.getMsg') == -1
      syntax = esprima.parse source, comment: true, range: true, tokens: true
      tokens = syntax.tokens.concat syntax.comments
      sortTokens tokens
      for token, i in tokens
        continue if token.type != "Identifier" || token.value != 'getMsg'
        message = getMessage tokens, i
        continue if !message
        description = getMessageDescription tokens, i
        continue if !description
        dictionary[message] ?= {}
        dictionary[message][description] = 'to translate: ' + message

    ###
      Merge new dictionary into yet existing dictionaries. This is especially
      usefull for as you go localization.
    ###
    for language in languages
      languagePath = "#{projectPath}/#{language}.json"
      source = fs.readFileSync languagePath, 'utf8'
      json = JSON.parse source
      for message, translations of dictionary
        jsonMessage = json[message] ?= {}
        for description, translation of translations
          continue if jsonMessage[description]
          jsonMessage[description] = translation
      text = JSON.stringify json, null, 2
      fs.writeFileSync languagePath, text, 'utf8'
    return

sortTokens = (tokens) ->
  tokens.sort (a, b) ->
    if a.range[0] > b.range[0]
      1
    else if a.range[0] < b.range[0]
      -1
    else
      0

getMessage = (tokens, i) ->
  if  tokens[i + 1].type == 'Punctuator' &&
      tokens[i + 1].value == '(' &&
      tokens[i + 2].type == 'String'
        return tokens[i + 2].value.slice 1, -1
  ''

getMessageDescription = (tokens, i) ->
  loop
    token = tokens[--i]
    return '' if !token
    break if !(token.type in ['Identifier', 'Punctuator'])
  token = tokens[--i] if token.type == 'Keyword' && token.value == 'var'
  return '' if token.type != 'Block'
  description = token.value.split('@desc')[1]
  return '' if !description
  description.trim()

insertMessages = (callback) ->
  dictionaryPath = "assets/messages/#{options.project}/#{options.locale}.json"
  if !fs.existsSync dictionaryPath
    console.log "Missing dictionary: #{dictionaryPath}"
    callback()
    return
  getProjectPaths 'js-build', (scripts) ->
    source = fs.readFileSync dictionaryPath, 'utf8'
    dictionary = JSON.parse source

    for script in scripts
      source = fs.readFileSync script, 'utf8'
      # todo: add @desc check
      continue if source.indexOf('goog.getMsg') == -1

      syntax = esprima.parse source, comment: true, range: true, tokens: true
      tokens = syntax.tokens.concat syntax.comments
      sortTokens tokens
      replacements = []
      for token, i in tokens
        continue if token.type != "Identifier" || token.value != 'getMsg'
        message = getMessage tokens, i
        continue if !message
        description = getMessageDescription tokens, i
        continue if !description
        translatedMsg = dictionary[message]?[description]
        continue if !translatedMsg
        range = tokens[i + 2].range
        range[0]++
        range[1]--
        replacements.push
          start: range[0]
          end: range[1]
          msg: translatedMsg

      localizedSource = ''
      for replacement, i in replacements
        if i == 0
          localizedSource += source.slice 0, replacement.start
        localizedSource += replacement.msg
        next = replacements[i + 1]
        if next
          localizedSource += source.slice replacement.end, next.start
        else
          localizedSource += source.slice replacement.end
      localizedSource ||= source
      fs.writeFileSync script, localizedSource, 'utf8'

    callback()

getProjectPaths = (jsDir, callback) ->
  jsNamespaces = do ->
    namespaces = for dir in jsSubdirs
      "--root=assets/#{jsDir}/#{dir} "
    namespaces.join ''
  command = "python assets/js/google-closure/closure/bin/build/closurebuilder.py
    #{jsNamespaces}
    --namespace=\"#{options.project}.start\"
    --output_mode=list
    --compiler_jar=assets/js/dev/compiler.jar
    --compiler_flags=\"--js=assets/#{jsDir}/deps.js\""
  exec command, (err, stdout, stderr) ->
    if isClosureCompilationError stderr
      console.log stderr
      return
    scripts = []
    for script in stdout.split '\n'
      script = script.trim()
      scripts.push script if script
    callback scripts

isClosureCompilationError = (stderr) ->
  ~stderr?.indexOf(': WARNING - ') ||
  ~stderr?.indexOf(': ERROR - ') ||
  # for closurebuilder.py errors
  ~stderr?.indexOf('JavaScript compilation failed.') ||
  ~stderr?.indexOf('Traceback (most recent call last):')

exports.start = start