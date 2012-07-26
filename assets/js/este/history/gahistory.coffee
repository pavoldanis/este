###*
  @fileoverview Google Analytics tracking history

  @author jiri.kopsa(at)proactify.com (Jiří Kopsa)
###

goog.provide 'este.history.GAHistory'

goog.require 'este.History'

###*
  @param {string} gaAccountId
  @param {boolean} forceHash If true, este.History will degrade to hash even if html5history is supported
  @param {string=} pathPrefix
  @constructor
  @extends {este.History}
###
este.history.GAHistory = (gaAccountId, forceHash, pathPrefix) ->
  # Initialize Google Analytics async queue
  if !window['_gaq']
    window['_gaq'] = [];

  # Set the tracker ID
  window['_gaq'].push(['_setAccount', gaAccountId]);

  # Need to call super constructor after we have gaq as it will trigger onNavigate
  goog.base @, forceHash, pathPrefix

  # Start loading the script
  `var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);`

  return

goog.inherits este.history.GAHistory, este.History

goog.scope ->
  `var _ = este.history.GAHistory`

  ###*
    @param {goog.history.Event} e
  ###
  _::onNavigate = (e) ->
    goog.base @, 'onNavigate', e

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
  _::logger_ = goog.debug.Logger.getLogger 'este.history.GAHistory'


  return