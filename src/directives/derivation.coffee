angular.module 'vconfl'
  .directive 'derivation', ->
    directive =
      restrict: 'AE'
      scope:
        derivations: '='
      templateUrl: 'directives/derivation.html'
      controller: 'DerivationController'