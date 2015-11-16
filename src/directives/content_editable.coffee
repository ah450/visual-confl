angular.module 'vconfl'
  .directive 'contenteditable', (srcTransform) ->
    directive =
      restrict: 'A'
      require: '?ngModel'
      link: (scope, element, attrs, ngModel) ->
        return if not ngModel
        read = ->
          html = element.html()
          html = '' if html == '<br>'
          ngModel.$setViewValue html
        ngModel.$render = ->
          transformedHTML = srcTransform(ngModel.$viewValue || '\n')
          element.html transformedHTML
        element.on 'blur keyup change', ->
          scope.$evalAsync read

