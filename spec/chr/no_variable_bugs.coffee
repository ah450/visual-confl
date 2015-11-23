###
Ensuring known bugs and issues stay resolved
###


describe 'No variables no guards bugs', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_) ->
    @parseCHR = _parseCHR_
  beforeEach ->
    @programSrc = """
    a, b <=> true.
    b => d.
    """
    @inputSrc = 'b, a.'

  context 'initial state', ->
    beforeEach ->
      @parsedProgram = @parseCHR @programSrc
      @parsedInput = @parsedProgram.parseInput @inputSrc
      @state = @parsedProgram.newState()

    it 'should not have any possible computations', ->
      expect(@state.hasComputation).to.be.false

    it 'should be considered a success state', ->
      expect(@state.isSuccess).to.be.true

    it 'should not be considered a failed state', ->
      expect(@state.isFailed).to.be.false

    context 'with goals', ->
      beforeEach ->
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

      context 'after first introduction', ->
        beforeEach ->
          @state.takeStep()

        it 'should still be able to introduce', ->
          expect(@state.canIntroduce).to.be.true

        it 'should have a b in its constraint store', ->
          expect(@state.CU.length).to.eql 1
          expect(@state.CU[0]).to.have.property('name', 'b')

      context 'final state', ->
        beforeEach ->
          while @state.hasComputation
            @state.takeStep()

        it 'should be a success state', ->
          expect(@state.isSuccess).to.be.true

        it 'Should have d and true in its constraint store', ->
          expect(@state.CU.length).to.eql 2
          expect(@state.CU[0]).to.have.property('name', 'd')
          expect(@state.CU[1]).to.have.property('name', 'true')

