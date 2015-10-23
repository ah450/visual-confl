angular.module 'vconfl'
  .config ($stateProvider) ->
    error =
      name: 'error'
      url: '/oops'
      templateUrl: 'error/root.html'
      abstract: true
      resolve:
        $title: ->
          'Error'

    internal =
      name: 'error.internal'
      url: '/internal'
      views:
        'errorContent':
          templateUrl: 'error/internal.html'
      resolve:
        $title: ->
          'Something went wrong'

    $stateProvider
      .state error
      .state internal

