###
Prototype for CHRProgram objects
Responsible for representation of CHRPrograms
###
angular.module 'chr'
  .factory 'CHRProgram', (Rule, unify) ->

    class CHRProgram
      constructor: (rules) ->
        @rules = (new Rule rule for rule in rules)

      ###
      Checks to see the array of goals is implied by the Constraint Theory
      (logically follows)
      ###
      isImplied: (kb, goals) ->
        true
      ###
        Attempts to unify two formulas.
        Expects formulas to be arrays of constraints or variables and atoms
        @returns Object representing substitutions, false if can't unify
      ###
      unify: (lhs, rhs) ->
        substitutions = {}
        return false if not unify lhs, rhs, substitutions
        return substitutions
        

    