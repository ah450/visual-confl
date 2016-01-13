###
Checks if two constraints are equal.
###

angular.module 'chr'
  .factory 'compareConstraints', ->
    (lhs, rhs) ->
      lhs.name is rhs.name