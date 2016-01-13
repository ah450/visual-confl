###
A directive for representing a critical pair
###

angular.module 'vconfl'
  .directive 'pairGraph', ->
    directive =
      restrict: 'A'
      scope:
        pair: '='
      link: (scope, element) ->
        ctx = element[0].getContext '2d'
        
