###*
  @fileoverview A JSONP requestor with improved ability to signal errors.
  Servers may signal errors with a second callback argument. This resemblers
  an HTTP status code that would be used if the response was not JSONP. If such
  error is signalled and the status is different from 200, opt_errorCallback is
  invoked rather than opt_replyCallback.

  Example success JSONP response:
    callback_function({"foo":"bar"});
    callback_function({"foo":"bar"}, 200);

  Example failure JSONP response:
    callback_function({"foo":"bar"}, 500);

  Background
    This is needed as all JSONP responses must be sent with 200 HTTP status
    code, hence there is no ability for goog.net.Jsonp to recognize the error.
    Signalling errors through payload is quite cumbersome, so we rather signal
    error through a second callback argument.
  @author jiri.kopsa(at)proactify.com (Jiří Kopsa)

  todo (by steida)
    refactor to use goog result object
###

goog.provide 'este.net.Jsonp'

goog.require 'goog.net.Jsonp'

class este.net.Jsonp extends goog.net.Jsonp

  ###*
    @param {goog.Uri|string} uri The Uri of the server side code that receives
       data posted through this channel (e.g.,
       "http://maps.google.com/maps/geo").
    @param {string=} opt_callbackParamName The parameter name that is used to specify the callback.
      Defaults to "callback".
    @constructor
    @extends {goog.net.Jsonp}
  ###
  constructor: (uri, opt_callbackParamName) ->
    super uri, opt_callbackParamName

  ###*
   @param {Object=} opt_payload Name-value pairs.  If given, these will be
       added as parameters to the supplied URI as GET parameters to the
       given server URI.
   @param {Function=} opt_replyCallback A function expecting one
       argument, called when the reply arrives, with the response data.
   @param {Function=} opt_errorCallback A function expecting one
       argument, called on timeout, with the payload (if given), otherwise
       null.
   @param {string=} opt_callbackParamValue Value to be used as the
       parameter value for the callback parameter (callbackParamName).
       To be used when the value needs to be fixed by the client for a
       particular request, to make use of the cached responses for the request.
       NOTE: If multiple requests are made with the same
       opt_callbackParamValue, only the last call will work whenever the
       response comes back.
   @return {Object} A request descriptor that may be used to cancel this
       transmission, or null, if the message may not be cancelled.
  ###
  send: (opt_payload, opt_replyCallback, opt_errorCallback, opt_callbackParamValue) ->
    super opt_payload, (data, status) ->
      if status && (status != 200)
        opt_errorCallback.apply undefined, arguments
      else
        opt_replyCallback.apply undefined, arguments
    , opt_errorCallback, opt_callbackParamValue