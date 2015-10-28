angular.module 'chr'
  .factory 'isVariable', ->
    (x) ->
      notInteger = isNaN parseInt x, 10
      if typeof x is 'string'
        isVarString = x.charAt(0).toUpperCase() == x.charAt(0)
      else
        isVarString = false
      return notInteger and isVarString