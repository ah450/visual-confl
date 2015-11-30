angular.module 'vconfl'
  .controller 'DerivationController', ($scope) ->
    $scope.representConstraintStore = (derivation) ->
      store = derivation.store.map _.property 'name'
      return "#{store.join(', ')}."

    $scope.representConstraint = (constraint) ->
      return constraint.name