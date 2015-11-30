angular.module 'vconfl'
  .controller 'ConfluenceCheckController', ($scope, confluenceData, confluenceChecker, parseCHR) ->
    $scope.processing = true

    processProgram = (program) ->
      checkResults = confluenceChecker program
      $scope.pairs = checkResults.pairs
      $scope.isConfluent = checkResults.isConfluent
      $scope.processing = false

    program = confluenceData.program
    $scope.$evalAsync _.partial processProgram, program