angular.module 'chr'
  .factory 'State', (isBuiltInConstraint) ->
    class State
      constructor: (@chrProgram, @GSU=[], @GSB=[], @CU=[], @CUHASH=[],
        @BI=[]) ->
        @applicableRules = []
        @appliedPropagations = {}
        @variables = []
        @hasFalse = false
        @tracker = angular.noop
        
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
        constraint = @GSB.shift()
        action =
          type: 'solve'
          constraint: constraint
        @tracker action
        @solveHelper constraint

      introduce: ->
        constraint = @GSU.shift()
        action =
          type: 'introduce'
          constraint: constraint
        @tracker action
        @introductionHelper constraint

      introductionHelper: (constraint) ->
        @CU.push constraint
        (@CUHASH[constraint.name] or=[]).push constraint

      solveHelper: (constraint) ->
        if constraint.name in ['false', 'true']
          if not @hasFalse
            hasWithName = _.some @BI, 'name', constraint.name
            @BI.push constraint if not hasWithName
            @hasFalse or= constraint.name is 'false'
            if @hasFalse
              _.remove @BI, 'name', 'true'
        else
          @BI.push constraint


      ###
      Propagation is adding user defined constraints to the user defined store
      by applying a propagation rule, removing the corrosponding token
      from the token store and finally normalizing the state
      ###
      @property 'canPropagate',
        get: ->
           _.some @applicableRules, 'isPropagation'

      ###
      Simplification is applying a simplification or simpigation rule
      on the user defined constraint store and normalizing the state.
      ###
      @property 'canSimplify',
        get: ->
          _.some @applicableRules, (r) ->
            not r.isPropagation

      @property 'isFailed',
        get: ->
          @hasFalse

      @property 'isSuccess',
        get: ->
          not @isFailed and not @hasComputation

      @property 'hasComputation',
        get: ->
          @canIntroduce || @canSolve || @canSimplify || @canPropagate

      # Returns a clean version of the store.
      # For display
      @property 'constraintStore',
        get: ->
          if @CU.length > 0
            return @CU.concat @BI.filter (c) ->
              c.name isnt 'true'
          else
            return @BI

      @property 'goalStore',
        get: ->
          if @GSU.length > 0
            return @GSU.concat @GSB.filter (c) ->
              c.name isnt 'true'
          else
            return @GSB


      ###
      Normalization function
      ###
      normalize: ->
        @normalizeApplicableHelper()

      applicableSimplificationHelper: (rule) ->
        return @isApplicable rule

      applicablePropagationHelper: (rule) ->
        return @isApplicable rule

      normalizeApplicableHelper: ->
        @applicableRules = []
        for rule in @chrProgram.rules
          if rule.isPropagation
            @applicableRules.push rule if @applicableSimplificationHelper rule
          else
            @applicableRules.push rule if @applicablePropagationHelper rule

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
            continue if constraint.id in (@appliedPropagations[rule.name] or=[])
            # Try to unify one of the constraints in the current store
            #  with the same name as the head constraint with it.
            #  If at least one unifies there is no reason to find more matches
            if @chrProgram.unify constraint, headConstraint
              applicableConstraints++
              break
        return applicableConstraints == rule.head.length

      propagate: (rule) ->
        # Collect constraints
        constraints = []
        ids =  (@appliedPropagations[rule.name] or=[])
        for hc in rule.head
          ###
          Make sure not to use a previously constraint
          ###
          for constraint in @CUHASH[hc.name]
            continue if constraint.id in ids
            constraints.push constraint
            ids.push constraint.id
            break
        # TODO check variable unification
        # TODO check guards
        @appliedPropagations[rule.name] = ids
        @applyBody rule, constraints
        action =
          type: 'propagate'
          rule: rule
          usedConstraints: constraints
        @tracker action
      
      applyBody: (rule, userConstraints) ->
        # TODO handle variable re-assignment
        rule.add.forEach (constraint) =>
          newConstraint = _.assign({}, constraint)
          if isBuiltInConstraint newConstraint
            @solveHelper newConstraint
          else
            @chrProgram.addID newConstraint
            @introductionHelper newConstraint

      simplify: (rule) ->
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
        action =
          type: 'simplify'
          rule: rule
          usedConstraints: constraints
        @tracker action

      handleSurvive: (rule, constraints) ->
        removed = constraints.filter (e) ->
          remove = true
          rule.survive.forEach (s) ->
            if s.name == e.name
              remove = false
              return
          return remove
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
      takeStep: (@tracker=angular.noop) ->
        if @canSolve
          @takeAction @solve.bind @
        else if @applicableRules.length > 0
          rule = @applicableRules[0]
          if rule.isPropagation
            @takeAction @propagate.bind @, rule
          else
            @takeAction @simplify.bind @, rule
        else if @canIntroduce
          @takeAction @introduce.bind @

      ###
      Utility function for marking all applicable propagation rules as
      applied, used with confluence check
      ###
      markApplicablePropagationsAsApplied: ->
        helper = =>
          applicablePropagationRules = _.filter @applicableRules, 'isPropagation'
          applicablePropagationRules.forEach (rule) =>
            ids = (@appliedPropagations[rule.name] or=[])
            constraints = []
            for hc in rule.head
              ###
              Make sure not to use a previously constraint
              ###
              for constraint in @CUHASH[hc.name]
                continue if constraint.id in ids
                constraints.push constraint
                ids.push constraint.id
            @appliedPropagations[rule.name] = ids
            @normalize()

        helper() while _.some @applicableRules, 'isPropagation'

      resetTracker: ->
        @tracker = angular.noop



