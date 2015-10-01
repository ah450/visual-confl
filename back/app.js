var io = require('socket.io')();
var fs = require('fs');
var path = require('path');
var exec = require('child_process').exec;
var temp = require('temp');
var util = require('util');
var rimraf = require('rimraf');

var conflCheckerPath = path.join(__dirname, 'conflchecker', 'conflcheck.pl');

function parseCAS(str) {
    var CAS = {
        originalString: str
    };
    var strNoBrackets = str.replace(/[\]\[]/,'');
    var closeParenIndex = strNoBrackets.indexOf(')');
    CAS.head = strNoBrackets.slice(0, closeParenIndex + 1);
    var rest = strNoBrackets.slice(closeParenIndex + 1);
    rest.split(',').filter(function(element){return element.length > 0;});
    CAS.unifier = rest[1];
    return CAS;
}

function parseState(str) {
    var state = {
        originalString: str
    };
    var re = /state\(\[(.*)\],\[(.*)\],\[(.*)\]\)/;
    var match = re.exec(str);
    if (match != null) {
        state.chrConstraints = match[1];
        state.builtinConstraints = match[2];
        state.vars = match[3];
    }
    return state;

}

function parseRule(str) {
    var re = /rule\(\((.*)\),\[(.*)\],\[(.*)\],\[(.*)\],\[(.*)\]\)/;
    var match = re.exec(str);
    var rule = {
        originalString: str
    };
    rule.ruleStr = match[1];
    rule.keptHead = match[2].split(',').filter(function(element){return element.length > 0;});
    rule.removedHead = match[3].split(',').filter(function(element) {return element.length > 0;});
    rule.guard = match[4].split(',').filter(function(element) {return element.length > 0;});
    rule.body = match[5].split(',').filter(function(element) {return element.length > 0;});
    return rule;
}

function parseOverlap(str) {
    return str.replace(/[\]\[]/, '');
}

function parseCriticalPair(str) {
    var lines = str.split('\n').filter(function(element) {
        return element.length > 0;
    });

    var pair = {};
    pair.CAS = parseCAS(lines[1]);
    pair.state_1 = parseState(lines[3]);
    pair.state_2 = parseState(lines[5]);
    pair.rule_1 = parseRule(lines[7]);
    pair.rule_2 = parseRule(lines[9]);
    pair.overlap = parseOverlap(lines[11]);
    return pair;
}

function extractCriticalPairs(str) {
    var pairs = [];
    str.split('===============================================================================').forEach(function(element) {
        if (element.length > 1) {
            pairs.push(parseCriticalPair(element));
        }
    });
    return pairs;
}

function parseDeriv(deriv) {
    deriv = deriv[1];
    lines = deriv.split('\n').filter(function(el) { return el.length > 1; }).splice(3);
    var toReturn = {};
    console.log(lines);
    toReturn.hasRulesForFirst = lines[1] != 'Rules for second';
    if(toReturn.hasRulesForFirst) {
        toReturn.first = [];
        for( var i = 1; i < lines.length; i++ ) {
            if (lines[i] == 'Rules for second') {
                break;
            }
            toReturn.first.push(lines[i]);

        }
    }

    toReturn.hasRulesForSecond = lines[lines.indexOf('Rules for second') + 1] != 'Derived states' ;
    if(toReturn.hasRulesForSecond) {
        toReturn.second = [];
        for( var i = lines.indexOf('Rules for second') + 1; i < lines.length; i++ ) {
            if (lines[i] == 'Derived states') {
                break;
            }
            toReturn.second.push(lines[i]);

        }
    }
    toReturn.hasRules = toReturn.hasRulesForSecond && toReturn.hasRulesForFirst;
    toReturn.derivedStates = {
        first: parseState(lines[lines.indexOf('Derived states') + 1]),
        second: parseState(lines[lines.indexOf('Derived states') + 2])
    }
    return toReturn;
}

function extractJoinabilityTests(str) {
    var input = str.split('*********************************************************************************').filter(function(element) {return element.length > 0;});
    var tests = [];
    input.slice(1, input.length -1 ).forEach(function(cpTestStr){
        var test = {};
        test.valid = cpTestStr.length > 18;
        if (test.valid) {
            test.joinable = cpTestStr.indexOf('This ciritical pair is joinable') >= 0;
            var lines = cpTestStr.split('\n').filter(function(element){return element.length > 0;});
            test.pair = {
                first: {},
                second: {}
            };
            test.CAS = parseCAS(lines[1]);
            test.pair.first.state = parseState(lines[3]);
            test.pair.second.state = parseState(lines[5]);
            test.pair.first.rule = parseRule(lines[7]);
            test.pair.second.rule = parseRule(lines[9]);
            test.pair.overlap = parseOverlap(lines[11]);
            test.pair.first.goal = lines[17];
            test.pair.second.goal = lines[18];
            var deriv = cpTestStr.split('Attempting all possible derivations');
            test.deriv = parseDeriv(deriv);
            tests.push(test);
        }
        
    });
    return tests;
};

io.on('connection', function (socket) {
    socket.on("check confluence", function(fileData) {
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

                var input = util.format('consult(\'%s\').\ncheck_confluence(\'%s\').\n', conflCheckerPath,
                    testFilePath);
                var command = util.format('echo "%s" | swipl', input);
                var options = {
                    encoding: 'utf8',
                    timeout: 0,
                    maxBuffer: 2000000*1024,
                    killSignal: 'SIGTERM',
                    cwd: dirPath,
                    env: process.env 
                };
                exec(command, options, function(err, stdout, stderr) {
                    var success = true;
                    if(err) {
                        succes = false;
                    }
                    var response = {};
                    // extract critical pairs
                    var rest = stdout.split('----------------------------------------------------------------------------------').filter(function(str) { return str.length > 0;});
                    response.criticalPairs = extractCriticalPairs(rest[0]);
                    rest = rest[1];
                    response.joinablityTest = extractJoinabilityTests(rest);
                    socket.emit('result', {success: success, message: response});
                    rimraf.sync(dirPath);
                }); //exec             
            }); // write file
        }); // mkdir
    }); // cehck confluence event
});

io.listen(8081);