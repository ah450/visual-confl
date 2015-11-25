angular.module 'chr'
  .factory 'isBuiltInConstraint', ->
    (c) ->
      if c instanceof Object
        return c.hasOwnProperty('name') and c.name in ['builtin', 'false', 'true']
      else
        return false