angular.module 'chr'
  .factory 'confluenceChecker', (findCriticalPairs, findDerivations) ->

    # Checks if a single critical pair is joinable
    checkPair = (program, pair) ->
      criticalPair =
        first: pair[0]
        second: pair[1]
        joinable: true
        overlap: pair[2]

      # Find final state of first rule
      criticalPair.derivationsFirst = findDerivations program, criticalPair.first
      # Find final state of second rule
      criticalPair.derivationsSecond = findDerivations program, criticalPair.second

      # Test if the two final states are joinable
      return criticalPair



    checker = (program) ->
      pairs = findCriticalPairs program
      checkFunc = _.partial checkPair, program
      pairs = _.map pairs, checkFunc
      isConfluent = _.all pairs, 'joinable'
      return {
        pairs: pairs,
        isConfluent: isConfluent
      }

    return checker