# Prototype extensions for built in objects
angular.module 'vconfl'
  .config ->
    if typeof Array::remove isnt 'function'
      Array::remove = (element) ->
        index = @indexOf element
        if index > -1
          @splice index, 1
          return true
        else
          return false
      Array::equals = (other) ->
        @length is other.length and @every (elem, index) =>
          elem is @[i]

angular.module 'vconfl'
  .config ->
    String::capitalize = ->
      return @charAt(0).toUpperCase() + @slice(1).toLowerCase()

angular.module 'vconfl'
  .config ->
    Function::property = (prop, desc) ->
      Object.defineProperty @::, prop, desc