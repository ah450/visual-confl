angular.module('services').factory('conflChecker', function(Host) {
        var checker = {
            socket: io(Host.ws),
            resultCallbacks: [],
        }

        var parseResults = function(input) {
            console.log(input);
        };

        checker.check = function(program) {
            this.socket.emit('check confluence', program);
        }

        checker.onResult = function(cb) {
            this.resultCallbacks.push(cb);
        }

        checker.removeOnResult = function(cb) {
            this.resultCallbacks.remove(cb);
        };

        checker.socket.on('result', function(response) {
            checker.resultCallbacks.forEach(function (cb) {
                cb(response.success, parseResults(response.message));
            });
        });

        return checker;

});