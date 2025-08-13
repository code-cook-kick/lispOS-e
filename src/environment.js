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

module.exports = Environment;
