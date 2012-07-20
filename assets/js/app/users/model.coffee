###*
  @fileoverview User Model.
###
goog.provide 'app.users.Model'

goog.require 'este.mvc.Model'

###*
  @constructor
  @extends {este.mvc.Model}
###
app.users.Model = ->
  return

goog.inherits app.users.Model, este.mvc.Model
  
goog.scope ->
  `var _ = app.users.Model`

  _::schema =
    'firstName':
      'set': este.mvc.setters.trim
      'validators':
        'required': este.mvc.validators.required

  return