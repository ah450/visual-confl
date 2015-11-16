angular.module 'vconfl'
  .controller 'HomeController', ($scope, parseCHR) ->
    initialProgram = """
    simplification @ a, b <=> c.
    propagation @ a => b.
    propagation @ c => d.
    simpigation @ d \\ c <=> true.
    saaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadlksjadaskljdlksajdlkjaasldkjasdkaslkdjksaljdklasjdklsjdklasdskladlkjl.
    """
    $scope.models =
      programSrc: initialProgram
    