angular.module 'chr'
  .factory 'isUserDefinedConstraint', ->
    (c) ->
      if c instanceof Object
        return c.hasOwnProperty('name') and c.name isnt 'builtin'
      else
        return false