###
Returns a parsing function for CHR programs
Based on /src/grammar/chr.pgjs PEG grammar file
Requires browser version of PEGjs
The parse function parses it's input and returns a new instance of CHRProgram
###
angular.module 'chr'
  .factory 'parseCHR', (CHRProgram) ->
    (input) ->
      new CHRProgram PEGParser.parse input
        