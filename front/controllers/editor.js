"use strict";
angular.module('vconflApp').controller('EditorController', function($scope, conflChecker) {
    var initialValue = ":- use_module(library(chr)).\n:- chr_constraint throw_coin/1.\n\n% One non-trivial overlap, leading to non-joinable critical pair\n\n% Program is not confluent.\n\nthrow_coin(Coin) <=> Coin = head.\n\nthrow_coin(Coin) <=> Coin = tail.";
    for (var i = 0; i < 15; i++) {
        initialValue += '\n';
    }
    var editorOptions = {
        lineNumbers: true,
        theme: "3024-night",
        indentUnits: 2,
        indentWithTabs: false,
        tabSize: 2,
        viewportMargin: Infinity,
        scrollbarStyle: "null",
        autofocus: true,
        value: initialValue
    }

    $scope.codeMirror = CodeMirror(document.getElementById('editor'), 
        editorOptions);

    $scope.checkProgram = function() {
        conflChecker.check($scope.codeMirror.getValue());
    };
});