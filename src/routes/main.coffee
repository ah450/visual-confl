angular.module 'vconfl'
  .config ($stateProvider) ->

    main =
      name: 'main'
      url: ''
      abstract: true
      templateUrl: 'root.html'

    home =
      name: 'main.home'
      url: ''
      views:
        'content@main':
          templateUrl: 'home/main.html'
          controller: 'HomeController'

    confluence =
      name: 'confl.home'
      url: '/check'
      views:
        'content@main':
          templateUrl: 'home/check.html'
          controller: 'ConfluenceCheckController'

    about =
      name: 'main.about'
      url: '/about'
      views:
        'content@main':
          templateUrl: 'about.html'

    $stateProvider
      .state main
      .state home
      .state about
