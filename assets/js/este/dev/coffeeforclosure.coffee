###*
  @fileoverview Fix CoffeeScript compiled code for Closure Compiler.
###
goog.provide 'este.dev.coffeeForClosure'
goog.provide 'este.dev.CoffeeForClosure'

###*
  @param {string} source
###
este.dev.coffeeForClosure = (source) ->
  coffeeForClosure = new este.dev.CoffeeForClosure source
  coffeeForClosure.fix()

###*
  @param {string} source
  @constructor
###
este.dev.CoffeeForClosure = (@source) ->
  # consider newlines canonization
  # str.replace(/(\r\n|\r|\n)/g, '\n');
  @replaces = []
  return

goog.scope ->
  `var _ = este.dev.CoffeeForClosure`

  ###*
    @type {string}
  ###
  _.random = do ->
    x = 2147483648
    Math.floor(Math.random() * x).toString(36) +
    Math.abs(Math.floor(Math.random() * x) ^ goog.now()).toString(36)

  ###*
    @type {string}
    @protected
  ###
  _::source

  ###*
    @type {string}
    @protected
  ###
  _::random

  ###*
    @type {Array}
    @protected
  ###
  _::replaces

  ###*
    @return {string}
  ###
  _::fix = ->
    @storeReplaces()
    source = null

    loop
      className = @getClassName()
      break if !className || source == @source
      source = @source

      superClass = @getSuperClass className
      
      if superClass
        @removeCoffeeExtends className
        @removeInjectedExtendsCode className
      else
        @removeClassVar className
      
      namespace = @getNamespaceFromWrapper className
      @fullQualifyProperties className, namespace
      @fullQualifyConstructor className, namespace
      
      if superClass
        @addGoogInherits className, namespace, superClass
        @fixSuperClassReference className, namespace
      
      @removeWrapper className, namespace, superClass

    @addNote()
    @restoreReplaces()
    @source

  ###*
    @return {string|undefined}
  ###
  _::getClassName = ->
    @source.match(/function ([A-Z][\w]*)/)?[1]

  ###*
    @param {string} className
    @return {string}
  ###
  _::getSuperClass = (className) ->
    regex = new RegExp "return #{className};[\\s]*\\}\\)\\(([\\w\\.]+)\\);"
    matches = @source.match regex
    return '' if !matches
    matches[1]

  ###*
    @param {string} className
  ###
  _::removeCoffeeExtends = (className) ->
    regex = new RegExp "__extends\\(#{className}, _super\\);", 'g'
    @remove regex

  ###*
    @param {string} className
  ###
  _::removeInjectedExtendsCode = (className) ->
    @remove """
      var #{className},
        __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };"""
    
    @remove """
      var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };"""

  ###*
    @param {string} className
  ###
  _::removeClassVar = (className) ->
    regex = new RegExp "var #{className};", 'g'
    @remove regex

  ###*
    @param {string|RegExp} value
    @protected
  ###
  _::remove = (value) ->
    @replace value, ''

  ###*
    @param {string|RegExp} value
    @param {string|Function} string
    @protected
  ###
  _::replace = (value, string) ->
    @source = @source.replace value, string

  ###*
    @param {string} className
    @return {string}
  ###
  _::getNamespaceFromWrapper = (className) ->
    regex = new RegExp "#{className} = \\(function\\((_super)?\\) \\{"
    index = @source.search regex
    return '' if index == -1
    letters = []
    while letter = @source.charAt --index
      break if letter in [' ', ';', '\n']
      letters.unshift letter
    letters.join ''
    
  ###*
    @param {string} className
    @param {string} namespace
  ###
  _::fullQualifyProperties = (className, namespace) ->
    regex = new RegExp className + '\\.(\\w+)', 'g'
    @replace regex, (match, prop) ->
      return match if prop == className
      return match if prop == '__super__'
      namespace + match

  ###*
    @param {string} className
    @param {string} namespace
  ###
  _::fullQualifyConstructor = (className, namespace) ->
    regex = new RegExp "function #{className}", 'g'
    if namespace
      @replace regex, namespace + className + ' = function'
    else
      @replace regex, 'var ' + className + ' = function'

  ###*
    @param {string} className
    @param {string} namespace
    @param {string} superClass
    @protected
  ###
  _::addGoogInherits = (className, namespace, superClass) ->
    # match constructor
    regex = new RegExp "#{namespace}#{className} = function\\(", 'g'
    index = @source.search regex
    return if index == -1

    # Looking for position after constructor, is a bit tricky, because function
    # can contains everything. Luckily, indentation works for us.
    lines = @source.slice(index).split '\n'

    for line, i in lines
      index += line.length + 1
      break if line == '  }'

    inherits = "\n  goog.inherits(#{namespace + className}, #{superClass});\n"
    @source = @source.slice(0, index) + inherits + @source.slice index

  ###*
    @param {string} className
    @param {string} namespace
    @protected
  ###
  _::fixSuperClassReference = (className, namespace) ->
    regex = new RegExp "#{className}\\.__super__", 'g'
    @replace regex, "#{namespace}#{className}\.superClass_"

  ###*
    @param {string} className
    @param {string} namespace
    @param {string} superClass
  ###
  _::removeWrapper = (className, namespace, superClass) ->
    # intro
    regex = new RegExp "#{namespace}#{className} = \\(function\\((_super)?\\) \\{"
    @remove regex
    # outro
    regex = new RegExp "return #{className};[\\s]*\\}\\)\\((#{superClass})?\\);", 'g'
    @remove regex

  ###*
    @protected
  ###
  _::addNote = ->
    @source =
      "// Fixed coffee code for Closure Compiler by este dev stack\n" + @source

  ###*
    @protected
  ###
  _::storeReplaces = ->
    @source = @source.replace /\$/g, (match) =>
      "xn2fs07c6n7ldollar_sucks_for_regexps"

    @source = @source.replace /\/\*[^*]*\*+([^\/][^*]*\*+)*\//g,
      (match) => "#{_.random}#{@replaces.push match}#{_.random}"

    # http://blog.stevenlevithan.com/archives/match-quoted-string
    @source = @source.replace /(["'])(?:(?=(\\?))\2.)*?\1/g, (match) =>
      "#{_.random}#{@replaces.push match}#{_.random}"

  ###*
    @protected
  ###
  _::restoreReplaces = ->
    for replace, i in @replaces
      @source = @source.replace "#{_.random}#{i + 1}#{_.random}", replace
    @source = @source.replace /xn2fs07c6n7ldollar_sucks_for_regexps/g,
      (match) => "$"
    return
  
  return

# just for sake of the Compiler
exports = exports || {}
exports.coffeeForClosure = este.dev.coffeeForClosure





