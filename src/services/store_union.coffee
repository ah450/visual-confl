angular.module 'chr'
  .factory 'storeUnion', (compareConstraints) ->
    (storeA, storeB) ->
      constraintHash = {}
      allConstraints = storeA.concat storeB
      union = []
      allConstraints.forEach (constraint) ->
        constraintHash[constraint.name] or= 0
        constraintHash[constraint.name]++
        if constraintHash[constraint.name] % 2 is 1
          union.push constraint
      return union