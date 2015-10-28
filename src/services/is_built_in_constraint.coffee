angular.module 'chr'
  .factory 'isBuiltInConstraint', ->
    (c) ->
      if c instanceof Object
        return c.hasOwnProperty('name') and c.name is 'builtin'
      else
        return false