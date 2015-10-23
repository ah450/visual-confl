angular.module 'vconfl'
  .directive 'contenteditable', ($sce) ->
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
          element.html $sce.getTrustedHtml ngModel.$viewValue || ''
        element.on 'blur keyup change', ->
          scope.$evalAsync read

