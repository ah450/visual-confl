###
Tests basic CHR parsing
###


describe 'CHRProgram', ->
  @parseCHR = null
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_) ->
    @parseCHR = _parseCHR_

  describe 'rule order', ->
    beforeEach ->
      @programSrc = """
        first @ a <=> true.
        second @ b => true.
        third @ d \\ a <=> k.
      """
      @parsedProgram = @parseCHR @programSrc

    it 'should preserve source order', ->
      expect(@parsedProgram.rules[0]).to.have.property('name', 'first')
      expect(@parsedProgram.rules[1]).to.have.property('name', 'second')
      expect(@parsedProgram.rules[2]).to.have.property('name', 'third')



  describe 'syntax errors', ->
    it 'should throw syntax errors', ->
      programSrc = "k( a, b(), c => true."
      parse = @parseCHR.bind @parseCHR, programSrc
      expect(parse).to.throw PEGParser.SyntaxError


  describe 'correct programs', ->

    it 'should correctly assign ids', ->
      programSrc = """
      leq(X,Y), leq(Y, Z) => leq(X, Z).
      leq(X, Y), leq(Y, X) <=> X = Y.
      """
      parsed = @parseCHR programSrc
      expect(parsed.rules[0].id).to.not.eql parsed.rules[1].id

    it "should correctly parse unamed version", ->
      programSrc = """
      leq(X,Y), leq(Y, Z) => leq(X, Z).
      leq(X, Y), leq(Y, X) <=> X = Y.
      """
      parse = @parseCHR.bind @parseCHR, programSrc
      expect(parse).to.not.throw()
    it 'should correctly parse named version', ->
      programSrc = """
      rule1 @ leq(X,Y), leq(Y, Z) => leq(X, Z).
      rule2 @ leq(X, Y), leq(Y, X) <=> X = Y.
      """
      parse = @parseCHR.bind @parseCHR, programSrc
      expect(parse).to.not.throw()

    it "should correctly parse progagation rules", ->
      programSrc = 'a => c.'
      program = @parseCHR programSrc
      rules = program.rules
      expect(rules).to.be.instanceOf Array
      expect(rules.length).to.eql 1
      rule = rules[0]
      expect(rule.isPropagation).to.be.true



    it 'should correctly parse implication rules with gaurds', ->
      programSrc = 'a(X), b(Y) => X = Y |  c.'
      program = @parseCHR programSrc
      rules = program.rules
      expect(rules).to.be.instanceOf Array
      expect(rules.length).to.eql 1
      rule = rules[0]
      expect(rule.isPropagation).to.be.true

    it "should correctly parse simplification rules", ->
      programSrc = 'a <=> b.'
      program = @parseCHR programSrc
      rules = program.rules
      expect(rules).to.be.instanceOf Array
      expect(rules.length).to.eql 1
      rule = rules[0]
      expect(rule.isSimplification).to.be.true

    it "should correctly parse simplification rules with gaurds", ->
      programSrc = 'a(K) <=>  K = 5 | b.'
      program = @parseCHR programSrc
      rules = program.rules
      expect(rules).to.be.instanceOf Array
      expect(rules.length).to.eql 1
      rule = rules[0]
      expect(rule.isSimplification).to.be.true

    it "should correctly parse simpifigation rules", ->
      programSrc = 'a \\ d <=> b.'
      program = @parseCHR programSrc
      rules = program.rules
      expect(rules).to.be.instanceOf Array
      expect(rules.length).to.eql 1
      rule = rules[0]
      expect(rule.isSimpigation).to.be.true

    it "should correctly parse simpifigation rules with gaurds", ->
      programSrc = 'a(W) \\ d <=> W = 420 | b.'
      program = @parseCHR programSrc
      rules = program.rules
      expect(rules).to.be.instanceOf Array
      expect(rules.length).to.eql 1
      rule = rules[0]
      expect(rule.isSimpigation).to.be.true
