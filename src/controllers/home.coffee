angular.module 'vconfl'
  .controller 'HomeController', ($scope, parseCHR, confluenceData, $q, $state) ->
    initialProgram = """
    simplification @ a, b <=> c.
    propagation @ a => b.
    propagation @ c => d.
    simpigation @ d \\ c <=> true.
    """
    confluenceData.programSrc ||= initialProgram

    $scope.models =
      programSrc: confluenceData.programSrc
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
        results = state.constraintStore.map _.property 'name'
        results = results.join ', '
        text = "#{results}."
        $scope.models.history.push {
          text: text,
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
      if ( angular.isUndefined(newValue) or newValue is null or
        newValue.length is 0)
          $scope.isValidProgram = false
          program = null
      else
        $scope.$evalAsync func
        
  
    
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

    $scope.checkConfluence = ->
      confluenceData.program = program
      confluenceData.programSrc = $scope.models.programSrc
      $state.go 'main.check'
