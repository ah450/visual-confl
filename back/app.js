var io = require('socket.io')();
var fs = require('fs');
var path = require('path');
var exec = require('child_process').exec;
var temp = require('temp');
var util = require('util');
var rimraf = require('rimraf');

var conflCheckerPath = path.join(__dirname, 'conflchecker', 'conflcheck.pl');

io.on('connection', function (socket) {
    socket.on("check confluence", function(fileData) {
        temp.mkdir('conflcheck', function (err, dirPath) {
            if (err) {
                socket.emit('result', {success: false, message: "Server failed to create temp directory" });
                throw err;
            }
            console.log("created dir", dirPath);
            var testFilePath = path.join(dirPath, 'test.pl');
            fs.writeFile(testFilePath, fileData, function(err) {
                if (err) {
                   socket.emit('result', {success: false, message: "Server failed to write test file"});
                   throw err;
                }

                var input = util.format('consult(\'%s\').\ncheck_confluence(\'%s\'), show_critical_pairs(\'%s\').\n', conflCheckerPath,
                    testFilePath, testFilePath);
                var command = util.format('echo "%s" | swipl', input)
                var options = {
                    encoding: 'utf8',
                    timeout: 0,
                    maxBuffer: 200*1024,
                    killSignal: 'SIGTERM',
                    cwd: dirPath,
                    env: process.env 
                };
                exec(command, options, function(err, stdout, stderr) {
                    var success = true;
                    if(err) {
                        succes = false;
                    }
                    socket.emit('result', {success: success, message: stdout});
                    rimraf.sync(dirPath);
                }); //exec             
            }); // write file
        }); // mkdir
    }); // cehck confluence event
});

io.listen(8081);