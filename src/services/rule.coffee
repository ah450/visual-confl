###
Prototype for CHR rules
###
angular.module 'chr'
  .factory 'Rule', (isVariable) ->
    class Rule
      TYPES: ['propagation', 'simplification', 'simpigation']
      constructor: (parsedRule, @chrProgram) ->
        for own k, v of parsedRule
          key = "parsed_" + k
          @[key] = v
        # parsed rule has properties
        # head, add, remove, guard, name
        # Determine type
        if @parsed_remove.length == 0
          @type = @TYPES[0]
        else if @parsed_remove.length != @parsed_head.length
          @type = @TYPES[2]
        else
          @type = @TYPES[1]

        @id = @parsed_id
  
        @variables = []
        variableMap = {}
        variableRenamer = (c) =>
          if c.hasOwnProperty 'args'
            c.args = c.args.map (arg) =>
              if isVariable arg
                if arg in @variables
                  return variableMap[arg]
                else
                  newName = @chrProgram.getNewVariableName
                  variableMap[arg] = newName
                  @variables.push newName
                  return newName
              else
                return arg
          return c

        @head = @parsed_head.map variableRenamer
        @body = @parsed_add.map variableRenamer
        @remove = @parsed_remove.map variableRenamer
        @add = @parsed_add.map variableRenamer
        @guard = @parsed_guard.map variableRenamer

        @computeSurvive()
        @computeRepresentation()

      
      @property 'name',
        get: ->
          @parsed_name

      @property 'isPropagation',
        get: ->
          @type == @TYPES[0]
      @property 'isSimplification',
        get: ->
          @type == @TYPES[1]

      @property 'isSimpigation',
        get: ->
          @type == @TYPES[2]

      @property 'hasGuard',
        get: ->
          @guard.length isnt 0

      computeRepresentation: ->
        operator = if @isPropagation then '=>' else "<=>"
        body = _.pluck @body, 'name'
          .join ', '

        if @isSimpigation
          removeNames = _.pluck @remove, 'name'
          keep = _.pluck @head, 'name'
            .filter (c) ->
              c not in removeNames
          head = "#{keep.join(', ')} \\ #{removeNames.join(', ')}"
        else
          head = _.pluck @head, 'name'
            .join ', '

        @representation = "#{head} #{operator} #{body}."

      ###
      @survive is an array of the head constraints that won't be removed
      by the application of this rule
      returns an array of atoms
      ###
      computeSurvive: ->
        if @isPropagation
          @survive = @head
        else if @isSimplification
          @survive = []
        else
          @survive = @head.filter (constraint) =>
            # return true if constraint is not in removed
            equals = (a, b) ->
              a.length is b.length and a.every (elem, i) ->
                elem is b[i]
            for removedConstraint in @remove
              if removedConstraint.name is constraint.name
                # False if they fully match in order to filter out, meaning it
                # Does not survive the rule's application
                return not equals removedConstraint.args,  constraint.args
            # True if it's not in remove
            return true

