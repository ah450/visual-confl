"use strict";
angular.module('vconflApp').controller('HomeController', function($scope, conflChecker) {
    $scope.editor = true;
    $scope.graph = false;

    $scope.showEditor = function() {
        $scope.editor = true;
        $scope.graph = false;
    };

    $scope.showGraph = function() {
        $scope.editor = false;
        $scope.graph = true;
    };
    conflChecker.onResult(function (status, data) {
        $scope.$apply(function() {
            if(status) {    
                $scope.showGraph();
            }
        });
    });
});