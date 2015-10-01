"use strict";
angular.module('vconflApp')
.config(function ($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/');

    $stateProvider
        .state('Home', {
                url: '/',
                templateUrl: "views/home.html",
                controller: "HomeController",
                onExit: function(){
                    for (var listener in scrollListeners) {
                        document.removeEventListener('scroll', listener);
                    }
                    scrollListeners = [];
                }
            }
        );
});