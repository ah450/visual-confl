angular.module 'chr'
  .factory 'findDerivations', ->
    
    findDerivations = (program, rule) ->
      derivations = []
      # Create a new empty state tied to the program
      initialState = program.newState()
      rule.head.forEach (c) ->
        initialState.addGoal c
      
      while initialState.canIntroduce
        func = initialState.introduce.bind initialState
        initialState.takeAction func
        # Mark all propagation rules as applied
        initialState.markApplicablePropagationsAsApplied()
      
      # Add body as goals
      rule.body.forEach (c) ->
        initialState.addGoal c
      # First step in derivations
      derivation = {}
      derivation.store = initialState.constraintStore
      derivation.action =
        type: 'initial'
      derivations.push derivation
      # Generate derivations
      while initialState.hasComputation
        derivation = {}
        tracker = (action) ->
          derivation.action = action
        initialState.takeStep tracker
        derivation.store = initialState.constraintStore
        derivations.push derivation
      return derivations

    return findDerivations