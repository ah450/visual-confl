###
Tests for finding derivations.
###

describe 'findDerivations', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_, _findDerivations_) ->
    @parseCHR = _parseCHR_
    @findDerivations = _findDerivations_

  context 'initial state', ->
    beforeEach ->
      programSrc = """
      p => q.
      r,q <=> true.
      r, p, q <=> s.
      s <=> p,q.
      """
      @parsedProgram = @parseCHR programSrc
      @rule = @parsedProgram.rules[1]
      @derivations = @findDerivations @parsedProgram, @rule

    it 'should have an initial derivation', ->
      expect(@derivations[0].action).to.have.property 'type', 'initial'

