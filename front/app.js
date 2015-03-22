"use strict";
var scrollListeners = [];

angular.module('vconflApp', ['ui.router', 'vconfl-templates', 'services']);

(function () {

    var getWsHost = function(){
        return 'http://' + location.hostname + ':8081'
    }
    angular.module('services', []).constant('Host', {
        'ws': getWsHost()
    });
})();


angular.module('vconflApp').config(function() {
    Array.prototype.remove = function(element) {
        var index = this.indexOf(element);
        if (index > -1) {
            this.splice(index, 1);
        }
    }
});