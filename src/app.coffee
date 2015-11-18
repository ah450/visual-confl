angular.module 'chr', []
angular.module 'vconfl', ['chr', 'ui.router', 'ui.router.title', 'appTemplates',
  'ngAnimate', 'angulartics', 'angulartics.google.analytics', 'ui.codemirror',
  'ui.event']


angular.module 'vconfl'
  .config ($urlMatcherFactoryProvider) ->
    $urlMatcherFactoryProvider.strictMode false