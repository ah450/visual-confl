angular.module 'chr'
  .factory 'State', ->
    class State
      constructor: (@chrProgram, @GSU=[], @GSB=[], @CU=[], @BI=[], @tokens=[]) ->
        @variables = []


      @isVariable: (x) ->
        # currently only ints and identifiers allowed, identifiers treated as variables if first letter is capital
        isInteger = isNan parseInt x, 10
        not (isInteger || (x.charAt(0).toLowerCase() == x.charAt(0)))

      detectVariables: ->
        @variables = []
        for constraint in @GS.concat @CU, @BI
          vars = constraint.args.filter  isVariable
          @variables = @variables.concat vars

      canIntroduce: ->
        @GSU.length isnt 0

      canSolve: ->
        @GSB.length isnt 0

      @canPropagate: ->
        hasTokens = @tokens.length > 0
        hasTokens && @tokens.reduce (prev, rule) ->
          prev && @chrProgram.isImplied @BI, rule.guard
        , true

      isFailed: ->
        "false" not in @BI

      hasComputation: ->
        @canIntroduce() || @canSolve() || @canPropagate() || @canSimplify()


        
      
    