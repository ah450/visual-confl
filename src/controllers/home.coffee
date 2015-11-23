angular.module 'vconfl'
  .controller 'HomeController', ($scope, parseCHR, $q) ->
    initialProgram = """
    simplification @ a, b <=> c.
    propagation @ a => b.
    propagation @ c => d.
    simpigation @ d \\ c <=> true.
    """
    $scope.models =
      programSrc: initialProgram
      history: []
      prompt: ''
      errorMessage: ''

    program = null
    $scope.isValidProgram = false
    $scope.running = false

    editorDeferred = $q.defer()
    editor = editorDeferred.promise
    docDeferred = $q.defer()
    doc = docDeferred.promise


    $scope.editorOptions =
      lineWrapping: true
      lineNumbers: true
      mode: 'chr'
      lineSeperator: '\n'

    $scope.editorLoaded = (editor) ->
      editorDeferred.resolve editor
      docDeferred.resolve editor.getDoc()



    parseProgram = (src) ->
      try
        program = parseCHR src
        $scope.isValidProgram = true
        return true
      catch syntaxError
        $scope.isValidProgram = false
        $scope.models.errorMessage = "#{syntaxError.line}:#{syntaxError.column} #{syntaxError.message}"
        return false


    parseInput = (src) ->
      try
        state = program.newState()
        goals = program.parseInput src
        $scope.models.prompt = ''
        goals.forEach (goal) ->
          state.addGoal goal
        while state.hasComputation
          state.takeStep()
        if state.isSuccess
          results = state.CU.map (c) ->
            c.name
          results = results.join ', '
          $scope.models.history.push {
            text: "#{results}.",
            result: true
          }
        else
          history.push {
            text: 'false',
            result: true
          }
        $scope.running = false
      catch syntaxError
        $scope.running = false
        console.error syntaxError
        $scope.models.history.push {
          text: syntaxError.message,
          error: true
        }
      
    $scope.$watch 'models.programSrc', (newValue) ->
      func = _.partial parseProgram, newValue
      console.log newValue
      $scope.$evalAsync func unless (
        angular.isUndefined(newValue) or newValue is null or
        newValue.length is 0)
    
    $scope.promptKey = (event)->
      if event.keyCode == keyKodes.special.enter
        if $scope.isValidProgram and $scope.models.prompt.length > 0
          $scope.running = true
          $scope.models.history.push {
            text: $scope.models.prompt,
            prompt: true
          }
          func = _.partial parseInput, $scope.models.prompt
          $scope.$evalAsync func
