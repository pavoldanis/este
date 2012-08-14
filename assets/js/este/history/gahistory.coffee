###*
  @fileoverview Google Analytics tracking history

  @author jiri.kopsa(at)proactify.com (Jiří Kopsa)
###

goog.provide 'este.history.GAHistory'

goog.require 'este.History'
goog.require 'goog.debug.Logger'

class este.history.GAHistory extends este.History

  ###*
    @param {string} gaAccountId
    @param {string=} pathPrefix Path prefix to use if storing tokens in the path.
    The path prefix should start and end with slash.
    @param {boolean=} forceHash If true, este.History will degrade to hash even
    if html5history is supported.
    @constructor
    @extends {este.History}
  ###
  constructor: (gaAccountId, pathPrefix, forceHash) ->
    # Initialize Google Analytics async queue
    window['_gaq'] = [] if !window['_gaq']

    # Set the tracker ID
    window['_gaq'].push(['_setAccount', gaAccountId]);

    # todo: make test
    # Need to call super constructor after we have gaq as it will trigger onNavigate
    # super pathPrefix, forceHash

    # Start loading the script
    `var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);`

  ###*
    @inheritDoc
  ###
  onNavigate: (e) ->
    super e

    # Compute the URL of the page; if app is running using hash-based history,
    # it will be tracked as html5 history based (i.e. no hashes, full URLs)
    url = window.location.protocol + "//" + window.location.host + @pathPrefix + @history.getToken()
    window['_gaq'].push ['_trackPageview', url]

    @logger_.info "GA: trackPageview: " + url
    return

  ###*
    @type {goog.debug.Logger}
    @private
  ###
  logger_: goog.debug.Logger.getLogger 'este.history.GAHistory'