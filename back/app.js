var io = require('socket.io');
var fs = require('fs');
var path = require('path');
var spawn = require('child_process').spawn;
var temp = require('temp');
var options = {stream: fs.createWriteStream('/var/log/sock_events.log', {flags: 'a'})};
var logger = require('socket.io-logger')(options);
var stream = require('stream');
var util = require('util');

io.use(logger);
var conflCheckerPath = path.join(__dirname, 'conflchecker', 'conflcheck.pl');

io.on('connection', function (socket) {

    socket.on('check confluence', function (fileData) {
        temp.mkdir('conflcheck', function (err, dirPath) {
            if (err) {
                socket.emit('result', {success: false, message: "Server failed to create temp directory" });
                throw err;
            }
            var testFilePath = path.join(dirPath, 'test.pl');
            fs.writeFile(testFilePath, fileData, function(err) {
                if (err) {
                   socket.emit('result', {success: false, message: "Server failed to write test file"});
                   throw err;
                }
                var s = new stream.Readable();
                s._read = function noop() {};
                s.push(util.format('consult(%s).\ncheck_confluence(%s), show_critical_pairs(%s).', conflCheckerPath,
                    testFilePath, testFilePath));
                s.push(null);
                var spawnOptions = {
                    cwd: dirPath,
                    stdio: [s, 'pipe', 'pipe']
                };
                var swipl= spawn('swipl', [], spawnOptions);
                swipl.on('close', function(code) {
                    socket.emit('result', {success: code == 0, message: swipl.stdout.read()});
                })
            });
        });
    });
});

io.listen(8080);