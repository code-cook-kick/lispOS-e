const Environment = require("./environment");
const { hostLoadFileSync } = require("./host/fs_bridge");
const { LispParser } = require("./parser");

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

/**
 * Convert JavaScript values back to AST nodes for macro expansion
 * This handles the conversion from evaluated macro results back to AST
 */
function jsValueToAST(value) {
    if (value === null || value === undefined) {
        return { type: "SYMBOL", value: "nil", children: [] };
    }
    
    if (typeof value === 'number') {
        return { type: "NUMBER", value: value, children: [] };
    }
    
    if (typeof value === 'string') {
        return { type: "STRING", value: value, children: [] };
    }
    
    if (typeof value === 'boolean') {
        return { type: "BOOLEAN", value: value, children: [] };
    }
    
    // Handle functions - they should not be converted, just return as symbol
    if (typeof value === 'function') {
        return { type: "SYMBOL", value: "function", children: [] };
    }
    
    // Handle AST nodes that are already properly formatted
    if (value && typeof value === 'object' && value.type) {
        return value;
    }
    
    // Handle arrays (lists)
    if (Array.isArray(value)) {
        return {
            type: "LIST",
            children: value.map(item => jsValueToAST(item)),
            value: null
        };
    }
    
    // Fallback: treat as symbol
    return { type: "SYMBOL", value: String(value), children: [] };
}

/**
 * Create a LIST AST node from an array of AST nodes
 */
function listAst(nodes, sourceInfo = null) {
    return {
        type: "LIST",
        children: nodes.slice(0), // defensive copy to prevent cycles
        value: null,
        sourceInfo: sourceInfo || null
    };
}

/**
 * Create a SYMBOL AST node
 */
function sym(name, sourceInfo = null) {
    return {
        type: "SYMBOL",
        value: name,
        children: [],
        sourceInfo: sourceInfo || null
    };
}

// Global expansion depth tracking to prevent infinite recursion
let expansionDepth = 0;
const MAX_EXPANSION_DEPTH = 200;

/**
 * Safely call a macro transformer with depth protection
 */
function callTransformer(transformer, rawArgs) {
    if (++expansionDepth > MAX_EXPANSION_DEPTH) {
        expansionDepth--;
        throw new Error("Macro expansion depth exceeded");
    }
    try {
        // transformer is a JS function that takes rawArgs array and returns AST
        const expanded = transformer(rawArgs);
        return expanded;
    } finally {
        expansionDepth--;
    }
}

/**
 * Bind macro parameters including variadic support
 */
function bindMacroParams(formalsAst, rawArgs, macroEnv) {
    const names = [];
    let variadicName = null;
    
    // Walk formalsAst.children; if you see a DOT "." then next SYMBOL is variadicName
    for (let i = 0; i < formalsAst.children.length; i++) {
        const n = formalsAst.children[i];
        if (n.type === "DOT" || (n.type === "SYMBOL" && n.value === ".")) {
            const restSym = formalsAst.children[i + 1];
            if (restSym && restSym.type === "SYMBOL") {
                variadicName = restSym.value;
                break; // Stop processing after finding variadic
            }
        }
        if (n.type === "SYMBOL") {
            names.push(n.value);
        }
    }
    
    // Fixed params
    for (let i = 0; i < names.length; i++) {
        const value = rawArgs[i] ?? sym("nil");
        macroEnv.define(names[i], value);
    }
    
    // Variadic tail as LIST AST of remaining raw args
    if (variadicName) {
        const tail = rawArgs.slice(names.length);     // raw AST array
        const tailList = listAst(tail);               // LIST AST
        macroEnv.define(variadicName, tailList);
    }
}

function evalList(list, env) {
    if (list.length === 0) return null;

    const [first, ...rest] = list;
    
    // Handle special forms first
    if (first.type === "SYMBOL") {
        switch (first.value) {
            case "define":
                return evalDefine(rest, env);
            case "lambda":
                return evalLambda(rest, env);
            case "if":
                return evalIf(rest, env);
            case "quote":
                return evalQuote(rest, env);
            case "list":
                return evalListForm(rest, env);
            case "defmacro":
                return evalDefmacro(rest, env);
        }
        
        // Macro expansion ONLY if head is a SYMBOL that names a macro
        const macroFn = env.lookupMacro && env.lookupMacro(first.value);
        if (macroFn) {
            // raw args = rest (UNEVALUATED AST nodes)
            try {
                const expanded = callTransformer(macroFn, rest); // returns AST
                const result = evalNode(expanded, env); // evaluate the expanded AST
                return result;
            } catch (error) {
                throw new Error(`Macro ${first.value} expansion failed: ${error.message}`);
            }
        }
    }
    
    // Normal call: evaluate head to a function, then args
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

/**
 * Evaluate if special form
 * Syntax: (if condition then-expr [else-expr])
 * - Evaluates condition first
 * - If truthy (not false or null), evaluates and returns then-expr
 * - If falsy and else-expr provided, evaluates and returns else-expr
 * - If falsy and no else-expr, returns null
 * Only the selected branch is evaluated (short-circuit evaluation)
 */
function evalIf(args, env) {
    if (args.length < 2 || args.length > 3) {
        throw new Error("if requires 2 or 3 arguments");
    }
    
    const [condNode, thenNode, elseNode] = args;
    const condValue = evalNode(condNode, env);
    
    // In Lisp, only #f (false) and nil are falsy
    const isTruthy = condValue !== false && condValue !== null;
    
    if (isTruthy) {
        return evalNode(thenNode, env);
    } else if (elseNode) {
        return evalNode(elseNode, env);
    } else {
        return null; // Return nil if no else clause
    }
}

/**
 * Evaluate quote special form
 * Syntax: (quote expr)
 * Returns the expression without evaluation
 */
function evalQuote(args, env) {
    if (args.length !== 1) {
        throw new Error("quote requires exactly 1 argument");
    }
    
    return args[0]; // Return the AST node without evaluation
}

/**
 * Evaluate defmacro special form
 * Syntax: (defmacro name (args...) body...)
 * Creates a macro transformer function that receives raw AST arguments
 * and returns an expanded AST form to be evaluated
 */
function evalDefmacro(args, env) {
    if (args.length !== 3) {
        throw new Error("defmacro requires exactly 3 arguments: name, parameters, body");
    }
    
    const [nameNode, paramsNode, bodyNode] = args;
    
    // Validate macro name
    if (nameNode.type !== "SYMBOL") {
        throw new Error("defmacro name must be a symbol");
    }
    
    // Validate parameter list
    if (paramsNode.type !== "LIST") {
        throw new Error("defmacro parameters must be a list");
    }
    
    // Create macro transformer function
    const macroTransformer = function(rawArgs) {
        // Create macro expansion environment
        // This is lexically scoped like lambda, but for macro expansion
        const macroEnv = new Environment(env);
        
        // Use the new parameter binding system
        bindMacroParams(paramsNode, rawArgs, macroEnv);
        
        // Evaluate macro body in expansion environment
        // The result should be an AST node ready for evaluation
        const expandedForm = evalNode(bodyNode, macroEnv);
        
        // Convert JavaScript values back to AST nodes for evaluation
        const astForm = jsValueToAST(expandedForm);
        
        return astForm;
    };
    
    // Register the macro
    env.defineMacro(nameNode.value, macroTransformer);
    
    // Return the macro name (like define returns the defined value)
    return nameNode.value;
}

function evalListForm(args, env) {
    return args.map(arg => evalNode(arg, env));
}

/**
 * Parse and evaluate a string containing LISP source code
 *
 * @param {string} src - LISP source code as string
 * @param {Environment} env - Environment to evaluate in
 * @returns {*} Value of the last top-level form, or null if empty
 */
function evalProgramFromString(src, env) {
    try {
        const parser = new LispParser(src);
        const program = parser.parse(); // returns array of AST nodes (top-level forms)
        
        let lastResult = null;
        for (const form of program) {
            lastResult = evalNode(form, env);
        }
        
        return lastResult;
    } catch (error) {
        // Return error object instead of throwing to allow graceful handling
        return {
            type: "error",
            message: `evalProgramFromString: ${error.message || error}`
        };
    }
}

function createGlobalEnv() {
    const env = new Environment();

    // Define nil constant
    env.define("nil", null);

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
        if (Array.isArray(list)) {
            return list.length;
        }
        // Handle AST LIST nodes from macro expansion
        if (list && typeof list === 'object' && list.type === 'LIST') {
            return list.children.length;
        }
        throw new Error("length requires a list or LIST AST node");
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
    
    env.define("first", (list) => {
        if (!Array.isArray(list)) {
            throw new Error("first requires a list");
        }
        return list.length > 0 ? list[0] : null;
    });
    
    env.define("second", (list) => {
        if (!Array.isArray(list)) {
            throw new Error("second requires a list");
        }
        return list.length > 1 ? list[1] : null;
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

    // File system bridge - host primitive for reading files
    env.define("host-load-file", (path) => {
        try {
            return hostLoadFileSync(path);
        } catch (error) {
            return {
                type: "error",
                message: String(error.message || error)
            };
        }
    });

    // Load function - loads and evaluates LISP files
    env.define("load", (path) => {
        // Get file content using host primitive
        const content = env.get("host-load-file")(path);
        
        // Check if file reading failed
        if (content && typeof content === 'object' && content.type === "error") {
            return content;
        }
        
        // Parse and evaluate the file content
        try {
            return evalProgramFromString(content, env);
        } catch (error) {
            return {
                type: "error",
                message: `load: ${String(error.message || error)}`
            };
        }
    });

    return env;
}

module.exports = { evalNode, createGlobalEnv, evalProgramFromString };
