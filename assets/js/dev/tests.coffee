###*
  @fileoverview Really fast unit testing.
###

fs = require 'fs'
{exec} = require 'child_process'

###*
  @return {Object.<string, Object>} Key is namespace, value is src, dependencies
###
getDeps = ->
  deps = {}
  goog = addDependency: (src, namespaces, dependencies) ->
    for namespace in namespaces
      deps[namespace] =
        src: src.replace '../../../', 'assets/js/'
        dependencies: dependencies
  depsFile = fs.readFileSync './assets/js/deps.js', 'utf8'
  eval depsFile
  deps

###*
  @return {Object.<string, string>} Key is filePath, value is textFilePath
###
getTestFiles = ->
  files = {}
  getDirectoryFiles 'assets/js', (testFilePath) ->
    return if testFilePath.indexOf('google-closure') > -1
    return if testFilePath.slice(-8) != '_test.js'
    filePath = testFilePath.slice(0, -8) + '.js'
    files[filePath] = testFilePath
  files

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

###*
  @param {Object} files
  @param {Object} deps
  @return {Array.<string>}
###
getNamespacesToTest = (files, deps) ->
  namespaces = [
    # we need that for DOM event simulation
    'goog.testing.events'
  ]
  for file, testFile of files
    for key, value of deps
      if value.src == file
        namespaces.push key
  namespaces

###*
  @param {Array.<string>} namespaces
  @param {Object} deps
  @return {Array.<string>}
###
resolveDeps = (namespaces, deps) ->
  files = []
  resolve = (namespaces) ->
    for namespace in namespaces
      continue if !deps[namespace]
      src = deps[namespace].src
      continue if files.indexOf(src) > -1
      resolve deps[namespace].dependencies
      files.push src
    return
  resolve namespaces
  files

###*
  @param {Array.<string>} depsFiles
  @param {Object.<string>} testFiles
  @return {Array.<string>}
###
getAllFiles = (depsFiles, testFiles) ->
  files = [
    'assets/js/dev/nodebase.js'
    'assets/js/dev/mocks.js'
  ]
  files.push.apply files, depsFiles
  for file, testFile of testFiles
    files.push testFile
  files

exports.run = (callback) ->
  deps = getDeps()
  testFiles = getTestFiles()
  namespaces = getNamespacesToTest testFiles, deps
  depsFiles = resolveDeps namespaces, deps
  files = getAllFiles depsFiles, testFiles
  command = "node assets/js/dev/node_modules/mocha/bin/mocha
    --colors
    --timeout 50
    --ui tdd
    --reporter min #{files.join ' '}"
  exec command, callback

exports.getDeps = getDeps