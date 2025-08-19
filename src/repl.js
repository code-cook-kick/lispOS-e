const readline = require("readline");
const { LispTokenizer } = require("./tokenizer");
const { evalNode, createGlobalEnv, ResourceError, DEFAULT_MAX_STEPS, DEFAULT_MAX_MACRO_EXPANSIONS, evalProgramFromString } = require("./evaluator");
const { LispParser } = require("./parser");
const { setAllowedRoots } = require("./host/fs_bridge");

// Parse command line arguments and environment variables for limits
function parseExecutionLimits() {
    const maxSteps = parseInt(process.env.ELISP_MAX_STEPS) ||
                    parseInt(process.argv.find(arg => arg.startsWith('--max-steps='))?.split('=')[1]) ||
                    DEFAULT_MAX_STEPS;
    
    const maxMacroExpansions = parseInt(process.env.ELISP_MAX_MACRO_EXPANSIONS) ||
                              parseInt(process.argv.find(arg => arg.startsWith('--max-macro-expansions='))?.split('=')[1]) ||
                              DEFAULT_MAX_MACRO_EXPANSIONS;
    
    const useTrampoline = process.env.ELISP_USE_TRAMPOLINE === 'true' ||
                         process.argv.includes('--use-trampoline');
    
    return { maxSteps, maxMacroExpansions, useTrampoline };
}

// Parse allowed roots from environment or CLI
function parseAllowedRoots() {
    const envRoots = process.env.ELISP_ALLOWED_ROOTS;
    const cliRoots = process.argv.find(arg => arg.startsWith('--allowed-roots='))?.split('=')[1];
    
    if (cliRoots) {
        return cliRoots.split(',').map(root => root.trim());
    }
    
    if (envRoots) {
        return envRoots.split(',').map(root => root.trim());
    }
    
    return null; // Use defaults
}

// Pretty print ResourceError with phase information
function formatResourceError(error) {
    if (error instanceof ResourceError) {
        return `🚫 Resource Limit Exceeded [${error.phase}]: ${error.message}`;
    }
    return error.message;
}

// Display help information
function showHelp() {
    console.log(`
Etherney eLisp REPL - Legal Reasoning System

Environment Variables:
  ELISP_MAX_STEPS              Maximum evaluation steps (default: ${DEFAULT_MAX_STEPS})
  ELISP_MAX_MACRO_EXPANSIONS   Maximum macro expansions (default: ${DEFAULT_MAX_MACRO_EXPANSIONS})
  ELISP_USE_TRAMPOLINE         Enable trampoline for tail calls (true/false)
  ELISP_ALLOWED_ROOTS          Comma-separated allowed root directories

Command Line Options:
  --max-steps=N                Set maximum evaluation steps
  --max-macro-expansions=N     Set maximum macro expansions
  --use-trampoline             Enable trampoline for tail calls
  --allowed-roots=path1,path2  Set allowed root directories
  --help                       Show this help message

Examples:
  ELISP_MAX_STEPS=50000 node src/repl.js
  node src/repl.js --max-steps=50000 --use-trampoline
  node src/repl.js --allowed-roots=/safe/dir1,/safe/dir2

REPL Commands:
  (help)                       Show LISP help
  (quit) or Ctrl+C            Exit REPL
`);
}

// Check for help flag
if (process.argv.includes('--help') || process.argv.includes('-h')) {
    showHelp();
    process.exit(0);
}

// Configure execution limits and security
const executionOptions = parseExecutionLimits();
const allowedRoots = parseAllowedRoots();

if (allowedRoots) {
    try {
        setAllowedRoots(allowedRoots);
        console.log(`📁 File access restricted to: ${allowedRoots.join(', ')}`);
    } catch (error) {
        console.error(`❌ Error setting allowed roots: ${error.message}`);
        process.exit(1);
    }
}

console.log(`🚀 Etherney eLisp REPL started`);
console.log(`⚙️  Limits: ${executionOptions.maxSteps} steps, ${executionOptions.maxMacroExpansions} macro expansions`);
console.log(`🔧 Trampoline: ${executionOptions.useTrampoline ? 'enabled' : 'disabled'}`);
console.log(`💡 Type --help for options, (help) for LISP help, (quit) to exit`);

const env = createGlobalEnv();

// Add REPL-specific functions
env.define("help", () => {
    console.log(`
LISP Built-in Functions:
  Arithmetic: +, -, *, /
  Comparison: =, <, >, <=, >=, !=, eq?
  Lists: list, cons, first, second, rest, nth, length
  Logic: and, or, not
  Control: if, let, lambda, define
  Macros: defmacro, gensym
  I/O: print, load, host-load-file
  Types: type-of
  Higher-order: map, filter, apply, map2

Special Forms:
  (define name value)          Define variable
  (lambda (args) body)         Create function
  (if condition then else)     Conditional
  (let ((var val)) body)       Local bindings
  (defmacro name (args) body)  Define macro
  (quote expr)                 Quote expression
  (load "file.lisp")          Load LISP file

Examples:
  (define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))
  (factorial 5)
  (load "src/lisp/example.lisp")
`);
    return null;
});

env.define("quit", () => {
    console.log("👋 Goodbye!");
    process.exit(0);
});

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "elisp> "
});

rl.prompt();

rl.on("line", (line) => {
    const trimmed = line.trim();
    
    // Skip empty lines
    if (!trimmed) {
        rl.prompt();
        return;
    }
    
    try {
        // Use evalProgramFromString with execution limits
        const result = evalProgramFromString(trimmed, env, executionOptions);
        
        // Check if result is an error object
        if (result && typeof result === 'object' && result.type === 'error') {
            console.error(`❌ ${formatResourceError(new Error(result.message))}`);
        } else {
            console.log(result);
        }
    } catch (err) {
        console.error(`❌ ${formatResourceError(err)}`);
    }
    
    rl.prompt();
});

rl.on("close", () => {
    console.log("\n👋 Goodbye!");
    process.exit(0);
});

// Handle Ctrl+C gracefully
process.on('SIGINT', () => {
    console.log("\n👋 Goodbye!");
    process.exit(0);
});
