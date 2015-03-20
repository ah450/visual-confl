"use strict";
angular.module('vconflApp')
.config(function ($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/');

    $stateProvider
        .state('Home', {
                url: '/',
                templateUrl: "views/home.html"
            }
        );
});