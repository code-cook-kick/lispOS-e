// Global gensym counter for unique symbol generation
let gensymCounter = 0;

/**
 * Generate unique symbol for macro hygiene
 * @param {string} prefix - Optional prefix for the generated symbol
 * @returns {string} Unique symbol name
 */
function gensym(prefix = 'G') {
    return `${prefix}__${++gensymCounter}`;
}

/**
 * Hygienic binding helper for macros
 * Creates a new environment with hygienic bindings to prevent variable capture
 * @param {Environment} env - Base environment
 * @param {Array} bindings - Array of [name, value] pairs
 * @returns {Environment} New environment with hygienic bindings
 */
function hygienicBind(env, bindings) {
    const newEnv = new Environment(env);
    const renameMap = new Map();
    
    // First pass: create unique names for all bindings
    for (const [name, value] of bindings) {
        const uniqueName = gensym(name);
        renameMap.set(name, uniqueName);
        newEnv.define(uniqueName, value);
    }
    
    // Store rename map for potential use in macro expansion
    newEnv._hygienicRenames = renameMap;
    
    return newEnv;
}

/**
 * Check if a symbol name is a generated gensym
 * @param {string} name - Symbol name to check
 * @returns {boolean} True if name appears to be a gensym
 */
function isGensym(name) {
    return typeof name === 'string' && /__\d+$/.test(name);
}

class Environment {
    constructor(parent = null) {
        this.vars = new Map();
        this.parent = parent;
        
        // Initialize macro registry - inherit from parent or create new
        if (parent && parent.macros) {
            // Share the same macro registry with parent (macros are global)
            this.macros = parent.macros;
        } else {
            // Only create new registry if this is the root environment
            this.macros = new Map();
        }
        
        // Macro registry methods - always available
        this.defineMacro = function(name, transformer) {
            this.macros.set(name, transformer);
        };
        
        this.lookupMacro = function(name) {
            return this.macros.get(name);
        };
        
        // Hygienic rename tracking for macro expansion
        this._hygienicRenames = null;
    }

    define(name, value) {
        this.vars.set(name, value);
    }

    set(name, value) {
        if (this.vars.has(name)) {
            this.vars.set(name, value);
            return;
        }
        if (this.parent) {
            this.parent.set(name, value);
            return;
        }
        throw new ReferenceError(`Undefined variable ${name}`);
    }

    get(name) {
        if (this.vars.has(name)) return this.vars.get(name);
        if (this.parent) return this.parent.get(name);
        throw new ReferenceError(`Undefined variable ${name}`);
    }
}

module.exports = {
    Environment,
    gensym,
    hygienicBind,
    isGensym
};
