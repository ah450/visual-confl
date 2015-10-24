angular.module 'vconfl'
  .config ($stateProvider) ->

    main =
      name: 'main'
      url: '/'
      abstract: true
      templateUrl: 'root.html'

    home =
      name: 'main.home'
      url: ''
      views:
        'content@main':
          templateUrl: 'home/main.html'
          controller: 'HomeController'

    about =
      name: 'about.home'
      url: '/about'
      views:
        'content@main':
          templateUrl: 'about.html'

    $stateProvider
      .state main
      .state home
      .state about
