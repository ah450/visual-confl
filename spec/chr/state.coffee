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

  describe 'no variables no guards', ->
    context 'initial state', ->
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

      context 'with goals', ->
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

        context 'after introduction', ->
          beforeEach ->
            @state.takeStep()

          it 'should no longer be able to introduce', ->
            expect(@state.canIntroduce).to.be.false

          it 'should have computations', ->
            expect(@state.hasComputation).to.be.true

          it "should not be able to simplify", ->
            expect(@state.canSimplify).to.be.false

          it 'should not be a failure state', ->
            expect(@state.isFailed).to.be.false

          it 'should be able to propagate', ->
            expect(@state.canPropagate).to.be.true

          it 'should not be a success state', ->
            expect(@state.isSuccess).to.be.false

          it 'should not be able to solve', ->
            expect(@state.canSolve).to.be.false

          context 'after propagation', ->
            beforeEach ->
              @state.takeStep()

            it 'should not be able to introduce', ->
              expect(@state.canIntroduce).to.be.false

            it 'should not be able to propagate', ->
              expect(@state.canPropagate).to.be.false

            it 'should not be able to solve', ->
              expect(@state.canSolve).to.be.false

            it 'should be able to simplify', ->
              expect(@state.canSimplify).to.be.true

            it 'should have computations', ->
              expect(@state.hasComputation).to.be.true

            it 'should not be a failure state', ->
              expect(@state.isFailed).to.be.false


            it 'should not be a success state', ->
              expect(@state.isSuccess).to.be.false

            context 'after simplification', ->
              beforeEach ->
                @state.takeStep()

              it 'should not be able to introduce', ->
                expect(@state.canIntroduce).to.be.false

              it 'should be able to propagate', ->
                expect(@state.canPropagate).to.be.true

              it 'should not be able to solve', ->
                expect(@state.canSolve).to.be.false

              it 'should not be able to simplify', ->
                expect(@state.canSimplify).to.be.false

              it 'should have computations', ->
                expect(@state.hasComputation).to.be.true

              it 'should not be a failure state', ->
                expect(@state.isFailed).to.be.false

              it 'should not be a success state', ->
                expect(@state.isSuccess).to.be.false

              context 'after second propagation', ->
                beforeEach ->
                  @state.takeStep()

                it 'should not be able to introduce', ->
                  expect(@state.canIntroduce).to.be.false

                it 'should not be able to propagate', ->
                  expect(@state.canPropagate).to.be.false

                it 'should not be able to solve', ->
                  expect(@state.canSolve).to.be.false

                it 'should be able to simplify', ->
                  expect(@state.canSimplify).to.be.true

                it 'should have computations', ->
                  expect(@state.hasComputation).to.be.true

                it 'should not be a failure state', ->
                  expect(@state.isFailed).to.be.false

                it 'should not be a success state', ->
                  expect(@state.isSuccess).to.be.false

                context 'after simpigation', ->
                  beforeEach ->
                    @state.takeStep()

                  it 'should not be able to introduce', ->
                    expect(@state.canIntroduce).to.be.false

                  it 'should not be able to propagate', ->
                    expect(@state.canPropagate).to.be.false

                  it 'should not be able to solve', ->
                    expect(@state.canSolve).to.be.false

                  it 'should not be able to simplify', ->
                    expect(@state.canSimplify).to.be.false

                  it 'should not have computations', ->
                    expect(@state.hasComputation).to.be.false

                  it 'should not be a failure state', ->
                    expect(@state.isFailed).to.be.false

                  it 'should be a success state', ->
                    expect(@state.isSuccess).to.be.true






