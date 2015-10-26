###
Test unification algorithm
###

describe 'Unification', ->
  @unify = null
  beforeEach module 'vconfl'
  beforeEach inject (_unify_) ->
    @unify = _unify_

  it 'should unify two variables', ->
    formulaOne = ['X']
    formulaTwo = ['Y']
    substitutions = {}
    
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.true
    expect(substitutions['X']).to.eql 'Y'

  it 'should unify two empty formulas', ->
    formulaOne = []
    formulaTwo = []
    substitutions = {}
    
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.true

  it 'should unify a nullary constraint', ->
    formulaOne = [
      name: 'a',
      args: []
    ]
    formulaTwo = [
      name: 'a'
      args: []
    ]
    
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.true

  it 'should not unify two different arrity constraints', ->
    formulaOne = [
      name: 'a',
      args: []
    ]
    formulaTwo = [
      name: 'a'
      args: [1, 2, 3, 4]
    ]
    
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.false

  it 'should not unify two different nullary constraints', ->
    formulaOne = [
      name: 'a',
      args: []
    ]
    formulaTwo = [
      name: 'b'
      args: []
    ]
    
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.false

  it 'should not unify two differently named constraints', ->
    formulaOne = [
      name: 'haha',
      args: [1, 2, 3]
    ]
    formulaTwo = [
      name: 'hehe'
      args: [1, 2, 3]
    ]
    
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.false

  it 'should unify two identical non nullary constraints without variables', ->
    formulaOne = [
      name: 'haha',
      args: [1, 2, 3]
    ]
    formulaTwo = [
      name: 'haha'
      args: [1, 2, 3]
    ]
    
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.true

  it 'should unify two identical non nullary constraints with variables', ->
    formulaOne = [
      name: 'haha',
      args: [1, 2, 3]
    ]
    formulaTwo = [
      name: 'haha'
      args: [1, 'X', 3]
    ]

    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.true

  it 'should unify a constraint with a variable', ->
    formulaOne = [
      name: 'haha',
      args: [1, 2, 3]
    ]
    formulaTwo = ['Y']
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.true
    expect(substitutions['Y'].name).to.eql formulaOne[0].name
    expect(substitutions['Y'].args).to.eql formulaOne[0].args

  it 'should fail when faced with inconsistent variable assignments', ->
    formulaOne = [1, 2, 3, 'X', 5, 6, 'X']
    formulaTwo = [1, 2, 3, 4, 5, 6, 7]
    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.false

  it 'should fail with inconsistent variables as part of predicates', ->
    formulaOne = [
      name: 'constraint',
      args: [1, 2, 3, 4, 5, 6, 7]
    ]
    formulaTwo = [
      name: 'constraint'
      args: [1, 2, 3, 'X', 5, 6, 'X']
    ]

    substitutions = {}
    value = @unify formulaOne, formulaTwo, substitutions
    expect(value).to.be.false


