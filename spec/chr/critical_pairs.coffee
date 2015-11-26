describe 'critical pairs', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_, _findCriticalPairs_) ->
    @parseCHR = _parseCHR_
    @findCriticalPairs = _findCriticalPairs_

  context 'one pair', ->
    beforeEach ->
      programSrc = """
      one @ p => q.
      two @ r,q <=> true.
      three @ r, p, q <=> s.
      four @ s <=> p,q.
      """
      @parsedProgram = @parseCHR programSrc
      @criticalPairs = @findCriticalPairs @parsedProgram

    it 'should have exactly two critical pair', ->
      expect(@criticalPairs).to.have.length 2

    it 'the critical overlaps are between rules (three, one) and (two, three)', ->
      firstPair = @criticalPairs[0]
      secondPair = @criticalPairs[1]
      test = (pair) ->
        names = _.map pair, 'name'
        ('three' in names and 'two' in names) or
          ('three' in names and 'one' in names)
      expect(test(firstPair)).to.be.true
      expect(test(secondPair)).to.be.true

    