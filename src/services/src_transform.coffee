angular.module 'vconfl'
  .factory 'srcTransform', ->
    (src) ->
      lines = src.split('\n').map (l, index) ->
        "<div><span><i>#{index + 1}</i></span><p>#{l}</p></div>"
      lines.join ''
