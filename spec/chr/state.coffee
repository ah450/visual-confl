###
Test state objects
###

describe 'State', ->
  ###
  We use CHR programs to create new states
  ###
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_) ->
    @parseCHR = _parseCHR_
  beforeEach ->
    @programSrc = """
    simplification @ a, b <=> c.
    propagation @ a => b.
    propagation @ c => d.
    simpigation @ d \\ c <=> true.
    """
    @inputSrc = 'a.'

  describe 'initial state', ->
    beforeEach ->
      @parsedProgram = @parseCHR @programSrc
      @parsedInput = @parsedProgram.parseInput @inputSrc
      @state = @parsedProgram.newState()

    it 'should not have any possible combinations', ->
      expect(@state.hasComputation).to.be.false

    it 'should be considered a success state', ->
      expect(@state.isSuccess).to.be.true

    it 'should not be considered a failed state', ->
      expect(@state.isFailed).to.be.false

    describe 'with goals', ->
      @beforeEach ->
        for goal in @parsedInput
          @state.addGoal goal

      it 'should not be a success or failed state initially', ->
        expect(@state.isFailed).to.be.false
        expect(@state.isSuccess).to.be.false

      it 'should be able to introduce only', ->
        expect(@state.hasComputation).to.be.true
        otherActions = [@state.canSolve, @state.canSimplify,
          @state.canPropagate].reduce (prev, current) ->
            prev || current
        expect(otherActions).to.be.false
        expect(@state.canIntroduce).to.be.true

      describe 'after introduction', ->
        beforeEach ->
          @state.takeStep()

        it 'should no longer be able to introduce', ->
          expect(@state.canIntroduce).to.be.false

        it 'should have computations', ->
          expect(@state.hasComputation)

