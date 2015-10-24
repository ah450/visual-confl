angular.module 'vconfl'
  .controller 'HomeController', ($scope, parseCHR) ->
    $scope.models =
      programSrc: ""
    