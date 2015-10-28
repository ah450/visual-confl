###
Enumerator for generating tokens
Enumerates lower case english alphabet only [a-z]
###
angular.module 'chr'
  .factory 'Enumerator', ->
    class Enumerator
      constructor: (@token=['a']) ->
      
      getToken: ->
        token = @token.join ""
        @incrementToken()
        return token

      incrementToken: ->
        # Generate the next token
        lastLetter = @token[@token.length - 1]
        isAllZs = =>
          @token.reduce (x, y) ->
            x && (y == 'z')
          , true
        if lastLetter != 'z'
          # Simply increment the end
          @token[@token.length - 1] =
            String.fromCharCode(lastLetter.charCodeAt(0) + 1)
        else if isAllZs()
          # If they are all 'z's then it's time to move on to the next length
          @token = ('a' for _ in @token)
          @token.push 'a'
        else
          # Remove last element and find the first non 'z'
          # and increment it recursively
          @token = @token[...-1]
          @incrementToken()

      reset: ->
        @token = ['a']
      
    