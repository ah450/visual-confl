###
Test program input parsing
###

describe 'Input', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_) ->
    @parseCHR = _parseCHR_
  beforeEach ->
    @inputSrc = ['b', 'k', 'd', 'j']
    @programSrc = 'a => b.'
    @parsedProgram = @parseCHR @programSrc
    @parsedInput = @parsedProgram.parseInput "#{@inputSrc.join(',')}."

  it 'should have same order as input', ->
    _.zip @parsedInput, @inputSrc
      .forEach (pair) ->
        parsed = pair[0]
        src = pair[1]
        expect(parsed).to.have.property('name', src)