{

  var OPERATOR = {
    PROPAGATION: 0,
    SIMPLIFICATION: 1
  }

  function buildBuiltInConstraint(left, operator, right) {
    return {
      left: left,
      right: right,
      operator: operator
    }
  }

  function transformBody(h1, simpigation, guard, operator, bodyConstraints) {
    var ruleBody = {}
    if (simpigation) {
      ruleBody.head = h1.concat(simpigation)
      ruleBody.remove = simpigation
    } else {
      ruleBody.head = h1
      ruleBody.remove = h1
    }

    if (operator == OPERATOR.PROPAGATION) {
      ruleBody.remove = []
    }
    ruleBody.guard = guard
    ruleBody.add = bodyConstraints
    return ruleBody;
  }

  function buildConstraint(name, args) {
    return {
      name: name.trim(),
      args: args
    }
  }

  function transformRule(name, body) {
    body.name = name? name : guid()
    return body
  }

  function guid() {
    function s4() {
      return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
      s4() + '-' + s4() + s4() + s4();
  }
}

start
  = _ rules:rule+ {return rules}

rule
  = name:ruleName? body:ruleBody _[\n\r]* {return transformRule(name, body)}

ruleBody
  = h1:constraintList _ simpigationKeep:simpigation? _ op:operator _ g:guard? _ bodyConstraints:constraintList {return transformBody(h1, simpigationKeep, g, op, bodyConstraints)}

constraintList
  = head:constraint _ "," _ tail:constraintList _ {return [head].concat(tail)}
  / c:constraint _ {return [c]}

simpigation
  = "\\" _ constraints:constraintList {return constraints}

operator
  = propagation / simplification

propagation
  = "=>" {return OPERATOR.PROPAGATION}

simplification
  = "<=>" {return OPERATOR.simplification}

ruleName
  = name:text "@" _ {return name.join("").trim()}

constraint
  = name:identifier "(" _ args:argList ")" {return buildConstraint(name, args)}
  / name:identifier {return buildConstraint(name, [])}

argList
  = head:arg _ "," _ tail:argList _ {return [head].concat(tail)}
  / a:arg _ {return [a]}

arg
  = integer
  / identifier

guard
  = _ constraints:builtinConstraintList _ "|" {return constraints}

builtinConstraintList
  = head:builtinConstraint _ "," _ tail:builtinConstraintList {return [head].concat(tail)}
  / c:builtinConstraint {return [c]}

builtinConstraint
  = left:arg _ op:binaryBuiltIn _ right:arg {return buildBuiltInConstraint(left, op, right)}

binaryBuiltIn
  = "="
  / "<"
  / "<="
  / ">"
  / ">="

text
 = [0-9a-zA-Z\t ]+

identifier
  = first:[a-zA-Z_] rest:[0-9a-zA-Z_]* {return first + rest.join("")}

integer
  = digits:[0-9]+ { return parseInt(digits.join(""), 10)}

_ "whitespace"
  = [ \t]*