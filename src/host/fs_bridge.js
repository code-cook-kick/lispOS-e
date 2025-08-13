/**
 * File System Bridge for Etherney eLisp
 * 
 * Provides safe file reading capabilities to the LISP environment.
 * This bridge only handles I/O operations - no legal logic is implemented here.
 */

const fs = require("fs");
const path = require("path");

/**
 * Synchronously reads a file and returns its content as UTF-8 text
 * 
 * @param {string} requestPath - The file path to read (relative or absolute)
 * @param {string} cwd - Current working directory for resolving relative paths
 * @returns {string} File content as UTF-8 text
 * @throws {Error} If path is invalid or file cannot be read
 */
function hostLoadFileSync(requestPath, cwd = process.cwd()) {
  // Validate input
  if (typeof requestPath !== "string" || requestPath.length === 0) {
    throw new Error("host-load-file: path must be a non-empty string");
  }
  
  // Resolve relative paths safely
  const abs = path.isAbsolute(requestPath) ? requestPath : path.resolve(cwd, requestPath);
  
  // Read file as UTF-8 text
  try {
    return fs.readFileSync(abs, "utf8");
  } catch (error) {
    // Re-throw with more context
    throw new Error(`host-load-file: Cannot read file '${requestPath}': ${error.message}`);
  }
}

module.exports = { hostLoadFileSync };