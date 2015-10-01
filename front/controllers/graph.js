"use strict";
angular.module('vconflApp').controller('GraphController', function($scope, conflChecker) {
    $scope.data = null;



    var elementToNode = function(element) {
        var ruleConstraints = {text: 'Constraints', children: []};
        
        if(element.state.builtinConstraints.length > 0) {
            ruleConstraints.children.push({text: element.state.builtinConstraints})
        }
        if(element.state.chrConstraints.length > 0) {
            ruleConstraints.children.push({text: element.state.chrConstraints})
        }
        var rule = {
            text: element.rule.ruleStr,
            children: [
                {text: 'goal', children: [{text: element.goal }]},
            ]
        };

        if (ruleConstraints.children.length > 0) {
            rule.children.push(ruleConstraints);
        }
        return rule;
    }


    conflChecker.onResult(function(status, data) {
        console.log(data);
        if (status) {
            $scope.$apply(function() {
                $scope.data = data;
                var confluence = data.joinablityTest.reduce(function(prev, current) {
                    return prev & current;
                }
                , true);
                $scope.confluence = confluence? "Confluent" : "Not confluent";

            });


            for (var i = 0; i < data.joinablityTest.length; i++) {
                var tree = TreeGraph('cp_container' + i);
                var cp = data.joinablityTest[i];
                var rootNode = {
                    text: cp.CAS.head
                };

                rootNode.children = [];
                
                rootNode.children.push(elementToNode(cp.pair.first));
                rootNode.children.push( {
                    text: 'overlap',
                    children: [{text: cp.pair.overlap}]
                });
                rootNode.children.push(elementToNode(cp.pair.second));
                if(cp.joinable) {
                    rootNode.children.push({text: 'joinable'})
                } else {
                    rootNode.children.push({text: 'Not joinable'})
                }
                tree.load(rootNode);
            };

            var rootNode = { // node to be loaded, which can have a lot of optional properties
                        text:'head', children:[
                            { text:'hello' },
                            { text:'world', children:[
                                { text:'other node' },
                                { text:'red' }
                            ] },
                            { text:'ba dum tss', children:[
                                { text:'little one', color:'#F2C9F1' },
                                { text:'lost cause', color:'#B6D991' },
                                { text:'round the bend', color:'#F6EB9F', children:[
                                    { text:'chuck', color:'#E3B9B2' },
                                    { text:'taylor', color:'#A1F3DC' }
                                ] }
                            ] },
                            { text:'a child', color:'#D9D' }
                        ]
                    };

                    // var tree = TreeGraph('cp_container'); // create instance, pass canvas ID
                    // tree.load(rootNode);
        }
    });

});