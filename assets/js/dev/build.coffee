fs = require 'fs'
{exec} = require 'child_process'

project = process.argv[2]

###
  Compile scripts with '--formatting=PRETTY_PRINT --debug=true'.
###
debug = '--debug' in process.argv

###
  Compile [project]-template.html for deployment.
###
deploy = '--deploy' in process.argv

###
  Compile just [project]-template.html.
###
onlyhtml = '--onlyhtml' in process.argv

start = Date.now()

###*
  @param {string} directory
  @param {Function} callback
###
getDirectoryFiles = (directory, callback) ->
  files = fs.readdirSync directory
  for file in files
    filePath = directory + '/' + file
    stats = fs.statSync filePath
    if stats.isFile()
      callback filePath
    if stats.isDirectory()
      getDirectoryFiles filePath, callback
  return

endsWith = (str, suffix) ->
  l = str.length - suffix.length
  l >= 0 && str.indexOf(suffix, l) == l

build = (project, flags) ->
  # flags are defined here http://goo.gl/hQ3yS
  if debug
    flagsText = ''
  else
    flagsText = "--compiler_flags=\"--define=goog.DEBUG=false\""
    # no need to recompile compiler
    # http://stackoverflow.com/questions/9797145/make-closure-compiler-strip-log-function-usages
    jsFiles = []
    getDirectoryFiles 'assets/js', (path) ->
      return if path.indexOf('google-closure') > -1
      jsFiles.push path if endsWith path, '.js'
    for jsFile in jsFiles
      source = fs.readFileSync jsFile, 'utf8'
      continue if source.indexOf('this.logger_.') == -1
      source = source.replace /this\.logger_\./g, 'goog.DEBUG && this.logger_.'
      fs.writeFileSync jsFile, source, 'utf8'

  if flags
    flagsText += "--compiler_flags=\"#{flag}\" " for flag in flags.split ' '

  fileName = project
  fileName += '_dev' if debug
  
  command = "
    python assets/js/google-closure/closure/bin/build/closurebuilder.py
      --root=assets/js/google-closure
      --root=assets/js/dev
      --root=assets/js/este
      --root=assets/js/#{project}
      --namespace=\"#{project}.start\"
      --output_mode=compiled
      --compiler_jar=assets/js/dev/compiler.jar
      --compiler_flags=\"--compilation_level=ADVANCED_OPTIMIZATIONS\"
      --compiler_flags=\"--jscomp_warning=visibility\"
      --compiler_flags=\"--warning_level=VERBOSE\"
      --compiler_flags=\"--output_wrapper=(function(){%output%})();\"
      --compiler_flags=\"--js=assets/js/deps.js\"
      #{flagsText}
      > assets/js/#{fileName}.js"

  exec command, (err, stdout, stderr) ->
    console.log stderr
    console.log "#{(Date.now() - start) / 1000}ms"

prepareIndexHtml = ->
  timestamp = (+new Date()).toString 36
  index = fs.readFileSync "./#{project}-template.html", 'utf8'
  if deploy
    scripts = """
      <script src='/assets/js/#{project}.js?build=#{timestamp}'></script>
      """
  else
    scripts = """
      <script src='/assets/js/google-closure/closure/goog/base.js'></script>
        <script src='/assets/js/deps.js'></script>
        <script src='/assets/js/#{project}/start.js'></script>
        """
  index = index.replace '###CLOSURESCRIPTS###', scripts
  index = index.replace /###BUILD_TIMESTAMP###/g, timestamp
  index = index.replace /###CONFIG_START###/g, ''
  index = index.replace /###CONFIG_END###/g, ''
  fs.writeFileSync "./#{project}.html", index, 'utf8'

prepareIndexHtml()

if !onlyhtml
  if debug
    build project, '--formatting=PRETTY_PRINT --debug=true'
  else
    build project

