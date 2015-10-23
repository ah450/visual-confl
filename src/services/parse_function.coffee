###
Returns a parsing function for CHR programs
Based on /src/grammar/chr.pgjs PEG grammar file
Requires browser version of PEGjs
The parse function parses it's input and returns a new instance of CHRProgram
###
angular.module 'chr'
  .factory 'ParseFunction', ($http, CHRProgram) ->
    $http.get '/grammar/chr.pegjs'
      .then (data) ->
        parser = PEG.buildParser(data, {optimize: "speed"})
        (input) ->
          new CHRProgram parser.parse input