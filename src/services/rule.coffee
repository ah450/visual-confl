###
Prototype for CHR rules
###
angular.module 'chr'
  .factory 'Rule', (enumerator) ->
    class Rule
      @TYPES = ['propagation', 'simplification', 'simpigation']
      constructor: (parsedRule) ->
        for own k, v of parsedRule
          key = "parsed_" + k
          @[key] = v
        # parsed rule has properties
        # head, add, remove, guard, name
        # Determine type
        if parsed_remove.length == 0
          @type = @TYPES[0]
        else if parsed_remove.length != parsed_head.length
          @type = @TYPES[2]
        else
          @type = @TYPES[1]

        # Construct constraint objects and rename variables
        @head = @parsed_head
        @body = @parsed_add
        @remove = @parsed_remove
        @add = @parsed_add
        @guard = @parsed_guard

      
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

      ###
      Returns an array of the head constraints that won't be removed
      by the application of this rule
      returns an array of atoms
      ###
      survive: ->
        return @head if @isPropagation
        return [] if @isSimplification
        @head.filter (constraint) =>
          # return true if constraint is not in removed
          equals = (a, b) ->
            a.length is b.length and a.every (elem, i) ->
              elem is b[i]
          for removedConstraint in @remove
            if removedConstraint.name is constraint.name
              # False if they fully match in order to filter out, meaning it
              # Does not survive the rule's application
              return not equals removedConstraint.args,  constraint.args
            break
          # True if it's not in remove
          return true

