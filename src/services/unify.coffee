angular.module 'chr'
  .factory 'unify', (isVariable) ->
    ###
    Helper for testing
    ###
    unify = (formulaOne, formulaTwo, substitutions) ->
      return false if formulaOne.length != formulaTwo.length
      return true if formulaOne.length == 0
      ###
      Helper for variable unification
      ###
      unifyVariable = (substitutions, variable, other) ->
        if substitutions.hasOwnProperty variable
          return unify substitutions, [substitutions[variable]], [other]
        if isVariable other
          if substitutions.hasOwnProperty other
            # other already has a substitution
            return unify substitutions, [variable], [substitutions[other]]
        # Other not a variable or both variables but no previous substitutions
        substitutions[variable] = other
        return true
      # Iterate over formula members, they are both the same length
      for lhs, index in formulaOne
        rhs = formulaTwo[index]
        if lhs == rhs
          continue
        else if isVariable lhs
          if not unifyVariable substitutions, lhs, rhs
            return false
        else if isVariable rhs
          if not unifyVariable substitutions, rhs, lhs
            return false
        else if (lhs instanceof Object and lhs.hasOwnProperty 'name') and
          (rhs instanceof Object and rhs.hasOwnProperty 'name')
            # constraints
            if lhs.name != rhs.name
              return false
            else
              if not unify lhs.args, rhs.args, substitutions
                return false
        else
          return false
      return true
      


          
        