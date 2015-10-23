angular.module 'vconfl'
  .controller 'HomeController', ($scope, parse) ->
    $scope.models =
      programSrc: ""
    