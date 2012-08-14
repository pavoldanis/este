###*
  @fileoverview Locale utils
  @author jiri.kopsa(at)proactify.com (Jiří Kopsa)
###

goog.provide 'este.Locale'

class este.Locale

  ###*
    @param {string} thousandsSeparator
    @param {string} decimalsSeparator
    @param {number} defaultDecimals
    @param {string} currency
    @param {boolean} currencyBefore
    @constructor
  ###
  constructor: (@thousandsSeparator,
    @decimalsSeparator,
    @defaultDecimals,
    @currency,
    @currencyBefore) ->

  ###*
    Formats price
    @param {string|number} number
  ###
  formatPrice: (number) ->
    if @currencyBefore
      return @currency + @number_format(number, @defaultDecimals)
    else
      return @number_format(number, @defaultDecimals) + @currency

  ###*
    Formats a number with grouped thousands
    Source: http://phpjs.org/functions/number_format:481
    @param {string|number} number
    @param {number} decimals
  ###
  number_format: (number, decimals) ->
    number = (number + '').replace(/[^0-9+\-Ee.]/g, '')
    n = if !isFinite(+number) then 0 else +number
    prec = if !isFinite(+decimals) then 0 else Math.abs(decimals)
    sep = if (typeof @thousandsSeparator == 'undefined') then ',' else @thousandsSeparator
    dec = if (typeof @decimalsSeparator == 'undefined') then '.' else @decimalsSeparator
    s = ''

    toFixedFix = (n, prec) ->
      k = Math.pow(10, prec)
      return '' + Math.round(n * k) / k

    # Fix for IE parseFloat(0.55).toFixed(0) = 0;
    s = (if prec then toFixedFix(n, prec) else '' + Math.round(n)).split('.')

    if (s[0].length > 3)
      s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep)
    if ((s[1] || '').length < prec)
      s[1] = s[1] || ''
      s[1] += new Array(prec - s[1].length + 1).join('0')

    s.join dec