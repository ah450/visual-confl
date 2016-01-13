describe 'store union', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_, _storeUnion_) ->
    @parseCHR = _parseCHR_
    @storeUnion = _storeUnion_

  context 'no variables', ->
    beforeEach ->
      programSrc = """
      one @ p => q.
      two @ r,q <=> true.
      three @ r, p, q <=> s.
      four @ s <=> p,q.
      """
      @parsedProgram = @parseCHR programSrc
      @inputA = 'a, b, c.'
      @inputB = 'b, d, q, a, a, a, a, c, c, c, r.'

      @getStore = (input) ->
        state = @parsedProgram.newState()
        parsedInput = @parsedProgram.parseInput input
        for goal in parsedInput
            state.addGoal goal
        while state.canIntroduce
          func = state.introduce.bind state
          state.takeAction func
          state.markApplicablePropagationsAsApplied()
        state.constraintStore

      @storeA = @getStore @inputA
      @storeB = @getStore @inputB
      @storeAB = @getStore 'b, q, a, a, a, c, c, d, r.'

    it 'should have correct length', ->
      union = @storeUnion @storeA, @storeB
      expect(union).to.have.length @storeAB.length

    it 'should have correct number of as', ->
      union = @storeUnion @storeA, @storeB
      countComputed = _.countBy union, {'name': 'a'}
      countExpected = _.countBy @storeAB, {'name': 'a'}
      expect(countComputed).to.eql countExpected

    it 'should have correct number of bs', ->
      union = @storeUnion @storeA, @storeB
      countComputed = _.countBy union, {'name': 'b'}
      countExpected = _.countBy @storeAB, {'name': 'b'}
      expect(countComputed).to.eql countExpected

    it 'should have correct number of cs', ->
      union = @storeUnion @storeA, @storeB
      countComputed = _.countBy union, {'name': 'c'}
      countExpected = _.countBy @storeAB, {'name': 'c'}
      expect(countComputed).to.eql countExpected

    it 'should have correct number of ds', ->
      union = @storeUnion @storeA, @storeB
      countComputed = _.countBy union, {'name': 'd'}
      countExpected = _.countBy @storeAB, {'name': 'd'}
      expect(countComputed).to.eql countExpected

    it 'should have correct number of qs', ->
      union = @storeUnion @storeA, @storeB
      countComputed = _.countBy union, {'name': 'q'}
      countExpected = _.countBy @storeAB, {'name': 'q'}
      expect(countComputed).to.eql countExpected

    it 'should have correct number of rs', ->
      union = @storeUnion @storeA, @storeB
      countComputed = _.countBy union, {'name': 'r'}
      countExpected = _.countBy @storeAB, {'name': 'r'}
      expect(countComputed).to.eql countExpected






