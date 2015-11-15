###
Prototype for CHRProgram objects
Responsible for representation of CHRPrograms
###
angular.module 'chr'
  .factory 'CHRProgram', (Rule, State, Enumerator, unify) ->

    groupByHeadArityHelper = (rules) ->
      rules.reduce (rulesHash, rule) ->
        headLength = rule.head.length
        (rulesHash[headLength] or=[]).push rule
        return rulesHash
      , {}


    class CHRProgram
      constructor: (rules) ->
        @enumerator = new Enumerator()
        @rules = (new Rule rule, @ for rule in rules)
        @currentID = Number.MIN_SAFE_INTEGER
        # Organize rules
        # Group simplification rules
        simplificationRules = @rules.filter (r) ->
          r.isSimplification || r.isSimpigation

        @simplificationRules = groupByHeadArityHelper simplificationRules

        # Group propagation rules
        propagationRules = @rules.filter (r) ->
          r.isPropagation
        @propagationRules = groupByHeadArityHelper propagationRules

      # Generates a brand new variable name
      getNewVariableName: ->
        @enumerator.getToken().toUpperCase()

      ###
      Adds an ID to a user defined constraint
      ###
      addID: (constraint) ->
        if not constraint.hasOwnProperty 'id'
          constraint.id = @currentID++
        return constraint

      ###
      Returns an empty State instance linked to this CHR program
      ###
      newState: ->
        new State @

      ###
      Checks to see the array of goals is implied by the Constraint Theory
      (logically follows)
      ###
      isImplied: (kb, goals) ->
        true

      parseInput: (inputSrc)->
        input = PEGParser.parse inputSrc, {
          startRule: 'input'
        }
        @addID constraint for constraint in input

      ###
        Attempts to unify two formulas.
        Expects formulas to be arrays of constraints or variables and atoms
        @returns Object representing substitutions, false if can't unify
      ###
      unify: (lhs, rhs, substitutions={}) ->
        return false if not unify lhs, rhs, substitutions
        return substitutions

    