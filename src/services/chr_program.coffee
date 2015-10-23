###
Prototype for CHRProgram objects
Responsible for representation of CHRPrograms
###
angular.module 'chr'
  .factory 'CHRProgram', (Rule, CTSolver) ->

    class CHRProgram
      constructor: (rules) ->
        @rules = (new Rule rule for rule in rules)


      ###
      Checks to see the array of goals is implied by the Constraint Theory
      (logically follows)
      ###
      isImplied: (kb, goals) ->
        CTSolver kb, goals
    