###
Helper function to find critical pairs in a CHR program
###

angular.module 'chr'
  .factory 'findCriticalPairs', (Combinatorics) ->
    findCriticalPairs = (chrProgram) ->
      simplificationRules = chrProgram.simplificationRules
      propagationRules = chrProgram.propagationRules
      if simplificationRules.length is 0
        return []
      
      possibilePairs = Combinatorics.combination simplificationRules, 2
        .toArray()

      if propagationRules.length > 0
        otherPairs = Combinatorics.cartesianProduct simplificationRules, propagationRules
          .toArray()
        possibilePairs = possibilePairs.concat otherPairs
      
      # Only keep pairs that have overlapping heads
      possibilePairs.filter (pair) ->
        heads = Combinatorics.cartesianProduct pair[0].head, pair[1].head
          .toArray()
        _.any heads, (headPair) ->
          chrProgram.unify [headPair[0]], [headPair[1]]


    return findCriticalPairs