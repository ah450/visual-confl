angular.module 'chr'
  .factory 'State', (isBuiltInConstraint) ->
    class State
      constructor: (@chrProgram, @GSU=[], @GSB=[], @CU=[], @CUHASH=[],
        @BI=[], @tokens=[], @variables=[], @appliedTokens={}) ->
          @applicableSimplifications = []
        
      detectVariables: ->
        @variables = []
        for constraint in @GS.concat @CU, @BI
          vars = constraint.args.filter  @chrProgram.isVariable
          @variables = @variables.concat vars

      ###
      Introduction is moving a user defined constraint from the goal store to
      the user defined store, updating the token store and normalizing the
      state.
      ###
      @property 'canIntroduce',
        get: ->
          @GSU.length isnt 0

      ###
      Solving is moving a built in constraint from the goal store to the built
      in store, and then normalizing the state.
      ###
      @property 'canSolve',
        get: ->
          @GSB.length isnt 0

      solve: ->
        @BI.push @GSB.pop()

      introduce: ->
        constraint = @GSU.pop()
        @introductionHelper constraint

      introductionHelper: (constraint) ->
        @CU.push constraint
        (@CUHASH[constraint.name] or=[]).push constraint


      ###
      Propagation is adding user defined constraints to the user defined store
      by applying a propagation rule, removing the corrosponding token
      from the token store and finally normalizing the state
      ###
      @property 'canPropagate',
        get: ->
          @tokens.length isnt 0

      ###
      Simplification is applying a simplification or simpigation rule
      on the user defined constraint store and normalizing the state.
      ###
      @property 'canSimplify',
        get: ->
          @applicableSimplifications.length isnt 0

      @property 'isFailed',
        get: ->
          "false" in @BI

      @property 'isSuccess',
        get: ->
          not @isFailed and not @hasComputation

      @property 'hasComputation',
        get: ->
          @canIntroduce || @canSolve || @canSimplify || @canPropagate

      ###
      Normalization function
      ###
      normalize: ->
        @normalizeApplicableHelper()

      applicableSimplificationHelper: ->
        @applicableSimplifications = []
        return if @CU.length == 0
        for i in [1..@CU.length]
          if @chrProgram.simplificationRules.hasOwnProperty i
            # Has rules with head of length i
            @chrProgram.simplificationRules[i].forEach (r) =>
              if @isApplicable r
                @applicableSimplifications.push r

      applicablePropagationHelper: ->
        @tokens = []
        return if @CU.length == 0
        for i in [1..@CU.length]
          if @chrProgram.propagationRules.hasOwnProperty i
            # Has rules with head of length i
            @chrProgram.propagationRules[i].forEach (r) =>
              if @isApplicable r
                @tokens.push r


      normalizeApplicableHelper: ->
        @applicableSimplificationHelper()
        @applicablePropagationHelper()


      ###
      Adds a goal, either a user defined constraint or a built in constraint.
      ###
      addGoal: (goal)->
        @takeAction @addGoalHelper.bind @, goal
      
      addGoalHelper: (goal) ->
        if isBuiltInConstraint goal
          @GSB.push goal
        else
          @GSU.push @chrProgram.addID goal
          

      ###
      Ensures state normalization after action
      ###
      takeAction: (action)->
        action()
        @normalize()

      ###
      Returns true if rule is applicable
      ###
      isApplicable: (rule) ->
        if rule.isPropagation
          @propagationApplicableHelper rule
        else
          @simplificationApplicableHelper rule

      ###
      A simplification or simpigation rule is applicable
      if there are user defined constraints that match the rule's head
      ###
      simplificationApplicableHelper: (rule) ->
        applicableConstraints = 0
        # Iterate over the constraints in the rule's head
        for headConstraint in rule.head
          # Check if we have constraints with same name
          return false if not @CUHASH.hasOwnProperty headConstraint.name
          # Try to unify one of the constraints in the current store
          #  with the same name as the head constraint with it.
          #  If at least one unifies there is no reason to find more matches
          for constraint in @CUHASH[headConstraint.name]
            if @chrProgram.unify constraint, headConstraint
              applicableConstraints++
              break
        return applicableConstraints == rule.head.length

      ###
      A propagation rule is applicable if there are
      user defined constraints that match the head that haven't been applied
      to this rule before.
      ###
      propagationApplicableHelper: (rule) ->
        applicableConstraints = 0
        # Iterate over the constraints in the rule's head
        for headConstraint in rule.head
          # Check if we have constraints with same name
          return false if not @CUHASH.hasOwnProperty headConstraint.name
          # Check if we have constraints with same name
          for constraint in @CUHASH[headConstraint.name]
            # Ignore constraint if it has already been used with this token
            continue if constraint.id in (@appliedTokens[rule.name] or=[])
            # Try to unify one of the constraints in the current store
            #  with the same name as the head constraint with it.
            #  If at least one unifies there is no reason to find more matches
            if @chrProgram.unify constraint, headConstraint
              applicableConstraints++
              break
        return applicableConstraints == rule.head.length

      propagate: ->
        # Grab first applicable propagation rule
        rule = @tokens[0]
        # Collect constraints
        constraints = []
        ids =  (@appliedTokens[rule.name] or=[])
        for hc in rule.head
          ###
          Make sure not to use a previously constraint
          ###
          for constraint in @CUHASH[hc.name]
            continue if constraint.id in ids
            constraints.push constraint
            ids.push constraint.id
        # TODO check variable unification
        # TODO check guards
        @appliedTokens[rule.name] = ids
        @applyBody rule, constraints

        
      
      applyBody: (rule, userConstraints) ->
        # TODO handle variable re-assignment
        rule.add.forEach (constraint) =>
          newConstraint = _.assign({}, constraint)
          @chrProgram.addID newConstraint
          @introductionHelper newConstraint

      simplify: ->
        # Grab any applicable simplification rule
        rule = @applicableSimplifications[0]
        # Collect constraints
        constraints = []
        for hc in rule.head
          for constraint in @CUHASH[hc.name]
            constraints.push constraint
        # TODO check variable unification
        # TODO check guards
        # Remove head constraints
        @handleSurvive rule, constraints
        # Add body constraints
        @applyBody rule, constraints

      handleSurvive: (rule, constraints) ->
        removed = constraints.filter (e) ->
          e not in rule.survive
        removedIDs = (c.id for c in removed)
        removed.forEach (constraint) =>
          @CUHASH[constraint.name] =
            @CUHASH[constraint.name].filter (other) ->
              other.id not in removedIDs
        @CU = @CU.filter (other) ->
          other.id not in removedIDs
          
      ###
      Takes a step if one is applicable
      ###
      takeStep: ->
        if @canSolve
          @takeAction @solve.bind @
        else if @canSimplify
          @takeAction @simplify.bind @
        else if @canPropagate
          @takeAction @propagate.bind @
        else if @canIntroduce
          @takeAction @introduce.bind @


        
      
    