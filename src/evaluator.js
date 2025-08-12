const Environment = require("./environment");

function isList(node) {
    return node.type === "LIST";
}

function evalNode(node, env) {
    switch (node.type) {
        case "NUMBER":
            return Number(node.value);
        case "STRING":
            return node.value;
        case "BOOLEAN":
            return node.value;
        case "SYMBOL":
            return env.get(node.value);
        case "LIST":
            return evalList(node.children, env);
        case "QUOTE":
            return node.children[0]; // return unevaluated AST
        default:
            return null;
    }
}

function evalList(list, env) {
    if (list.length === 0) return null;

    const [first, ...rest] = list;
    
    // Handle special forms
    if (first.type === "SYMBOL") {
        switch (first.value) {
            case "define":
                return evalDefine(rest, env);
            case "lambda":
                return evalLambda(rest, env);
            case "if":
                return evalIf(rest, env);
            case "list":
                return evalListForm(rest, env);
        }
    }
    
    // Regular function application
    const fn = evalNode(first, env);

    if (typeof fn === "function") {
        const args = rest.map(arg => evalNode(arg, env));
        return fn(...args);
    }

    throw new Error("Not a function: " + JSON.stringify(first));
}

function evalDefine(args, env) {
    if (args.length !== 2) {
        throw new Error("define requires exactly 2 arguments");
    }
    
    const [nameNode, valueNode] = args;
    if (nameNode.type !== "SYMBOL") {
        throw new Error("define requires a symbol as first argument");
    }
    
    const value = evalNode(valueNode, env);
    env.define(nameNode.value, value);
    return value;
}

function evalLambda(args, env) {
    if (args.length !== 2) {
        throw new Error("lambda requires exactly 2 arguments");
    }
    
    const [paramsNode, bodyNode] = args;
    if (paramsNode.type !== "LIST") {
        throw new Error("lambda parameters must be a list");
    }
    
    const paramNames = paramsNode.children.map(param => {
        if (param.type !== "SYMBOL") {
            throw new Error("lambda parameters must be symbols");
        }
        return param.value;
    });
    
    return function(...args) {
        if (args.length !== paramNames.length) {
            throw new Error(`Function expects ${paramNames.length} arguments, got ${args.length}`);
        }
        
        const newEnv = new Environment(env);
        for (let i = 0; i < paramNames.length; i++) {
            newEnv.define(paramNames[i], args[i]);
        }
        
        return evalNode(bodyNode, newEnv);
    };
}

function evalIf(args, env) {
    if (args.length !== 3) {
        throw new Error("if requires exactly 3 arguments");
    }
    
    const [condNode, thenNode, elseNode] = args;
    const condValue = evalNode(condNode, env);
    
    // In Lisp, only #f (false) and nil are falsy
    const isTruthy = condValue !== false && condValue !== null;
    
    return isTruthy ? evalNode(thenNode, env) : evalNode(elseNode, env);
}

function evalListForm(args, env) {
    return args.map(arg => evalNode(arg, env));
}

function createGlobalEnv() {
    const env = new Environment();

    // Basic math
    env.define("+", (...args) => args.reduce((a, b) => a + b, 0));
    env.define("-", (...args) => args.reduce((a, b) => a - b));
    env.define("*", (...args) => args.reduce((a, b) => a * b, 1));
    env.define("/", (...args) => args.reduce((a, b) => a / b));

    // Comparison operators
    env.define("=", (a, b) => a === b);
    env.define("<", (a, b) => a < b);
    env.define(">", (a, b) => a > b);
    env.define("<=", (a, b) => a <= b);
    env.define(">=", (a, b) => a >= b);
    env.define("!=", (a, b) => a !== b);

    // LISP built-in functions
    env.define("eq?", (a, b) => a === b);
    
    env.define("length", (list) => {
        if (!Array.isArray(list)) {
            throw new Error("length requires a list");
        }
        return list.length;
    });
    
    env.define("cons", (item, list) => {
        if (!Array.isArray(list)) {
            throw new Error("cons requires a list as second argument");
        }
        return [item, ...list];
    });
    
    env.define("nth", (list, index) => {
        if (!Array.isArray(list)) {
            throw new Error("nth requires a list as first argument");
        }
        if (typeof index !== 'number' || index < 0 || index >= list.length) {
            throw new Error("nth index out of bounds");
        }
        return list[index];
    });
    
    env.define("rest", (list) => {
        if (!Array.isArray(list)) {
            throw new Error("rest requires a list");
        }
        return list.slice(1);
    });
    
    env.define("map", (fn, list) => {
        if (typeof fn !== 'function') {
            throw new Error("map requires a function as first argument");
        }
        if (!Array.isArray(list)) {
            throw new Error("map requires a list as second argument");
        }
        return list.map(item => fn(item));
    });
    
    env.define("filter", (fn, list) => {
        if (typeof fn !== 'function') {
            throw new Error("filter requires a function as first argument");
        }
        if (!Array.isArray(list)) {
            throw new Error("filter requires a list as second argument");
        }
        return list.filter(item => fn(item));
    });

    // Printing
    env.define("print", (...args) => {
        console.log(...args);
        return args[args.length - 1];
    });

    return env;
}

module.exports = { evalNode, createGlobalEnv };
