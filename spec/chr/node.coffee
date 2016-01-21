###
Spec for node class
###


describe 'Node', ->
  @nodeClass = null
  beforeEach module 'vconfl'
  beforeEach inject (_Node_) ->
    @nodeClass = _Node_

  describe 'properties', ->
    beforeEach ->
      @node = new @nodeClass 0, 0, 1, 1

    it 'should have topLeft', ->
      expect(@node.topLeft).to.eql {x: 0, y: 0}

    it 'should have topRight', ->
      expect(@node.topRight).to.eql {x: 1, y: 0}

    it 'should have bottomLeft', ->
      expect(@node.bottomLeft).to.eql {x: 0, y: 1}

    it 'should have bottomRight', ->
      expect(@node.bottomRight).to.eql {x: 1, y: 1}

    it 'should have center', ->
      expect(@node.center).to.eql {x: 0.5, y: 0.5}