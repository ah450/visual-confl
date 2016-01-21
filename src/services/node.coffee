angular.module 'vconfl'
  .factory 'Node', ->
    class Node
      constructor: (@x, @y, @width, @height) ->
      
      getPosition: (widthRatio, heightRatio) ->
        return {
          x: @x + widthRatio * @width,
          y: @y + heightRatio * @height
        }

      @property 'center',
        get: ->
          @getPosition 0.5, 0.5

      @property 'topLeft',
        get: ->
          @getPosition 0, 0

      @property 'topRight',
        get: ->
          @getPosition 1, 0

      @property 'bottomLeft',
        get: ->
          @getPosition 0, 1

      @property 'bottomRight',
        get: ->
          @getPosition 1, 1