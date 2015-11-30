###
Tests for basic confluence check
###

describe 'confluence', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_) ->
    @parseCHR = _parseCHR_

  context 'non confluent', ->
    beforeEach ->
      programSrc = """
      p => q.
      r,q <=> true.
      r, p, q <=> s.
      s <=> p,q.
      """
      @parsedProgram = @parseCHR programSrc