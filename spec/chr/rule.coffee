###
Test rule objects
###

describe 'Rule', ->
  beforeEach module 'vconfl'
  beforeEach inject (_parseCHR_) ->
    @parseFunction = _parseCHR_

  describe 'simplification rules', ->
    beforeEach ->
      @r1 = @parseFunction "a, b, c <=> d."
      @r2 = @parseFunction "a(X), b(X), c(X) <=> X = 2 | d(X)."
      @r1 = @r1.rules[0]
      @r2 = @r2.rules[0]

    it 'should detect guard presence', ->
      expect(@r1.hasGuard).to.be.false
      expect(@r2.hasGuard).to.be.true

    describe 'survive', ->

      it 'nothing should survive', ->
        expect(@r1.survive.length).to.be.eql 0
        expect(@r2.survive.length).to.be.eql 0


  describe 'simpigation rules', ->
    beforeEach ->
      @r1 = @parseFunction "r, q \\ a, b, c <=> d."
      @r2 = @parseFunction "k \\ a(X), b(X), c(X) <=> X = 2 | d(X)."
      @r1 = @r1.rules[0]
      @r2 = @r2.rules[0]

    it 'should detect guard presence', ->
      expect(@r1.hasGuard).to.be.false
      expect(@r2.hasGuard).to.be.true

    describe 'survive', ->

      it 'Keep should survive', ->
        expect(@r1.survive.length).to.be.eql 2
        expect(@r2.survive.length).to.be.eql 1



  describe 'propagation rules', ->
    beforeEach ->
      @r1 = @parseFunction "a, b, c => d."
      @r2 = @parseFunction "a(X), b(X), c(X) => X = 2 | d(X)."
      @r1 = @r1.rules[0]
      @r2 = @r2.rules[0]

    it 'should detect guard presence', ->
      expect(@r1.hasGuard).to.be.false
      expect(@r2.hasGuard).to.be.true

    describe 'survive', ->

      it 'nothing should survive', ->
        expect(@r1.survive.length).to.be.eql 3
        expect(@r2.survive.length).to.be.eql 3


