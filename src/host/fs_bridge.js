/**
 * File System Bridge for Etherney eLisp
 *
 * Provides safe file reading capabilities to the LISP environment.
 * This bridge only handles I/O operations - no legal logic is implemented here.
 *
 * Security Features:
 * - Whitelist allowed root directories
 * - Prevent directory traversal attacks (..)
 * - Path normalization and validation
 */

const fs = require("fs");
const path = require("path");

// Default allowed roots - can be overridden via environment or configuration
const DEFAULT_ALLOWED_ROOTS = [
  process.cwd(),                    // Current working directory
  path.join(process.cwd(), 'src'),  // Source directory
  path.join(process.cwd(), 'lisp'), // LISP code directory
  path.join(process.cwd(), 'tests') // Tests directory
];

// Global allowed roots configuration
let allowedRoots = [...DEFAULT_ALLOWED_ROOTS];

/**
 * Set allowed root directories for file access
 * @param {string[]} roots - Array of absolute paths that are allowed as roots
 */
function setAllowedRoots(roots) {
  if (!Array.isArray(roots)) {
    throw new Error("setAllowedRoots: roots must be an array");
  }
  
  // Normalize and validate all root paths
  allowedRoots = roots.map(root => {
    if (typeof root !== 'string') {
      throw new Error("setAllowedRoots: all roots must be strings");
    }
    return path.resolve(root);
  });
}

/**
 * Get current allowed root directories
 * @returns {string[]} Array of allowed root paths
 */
function getAllowedRoots() {
  return [...allowedRoots];
}

/**
 * Check if a resolved path is within allowed roots
 * @param {string} resolvedPath - Absolute path to check
 * @returns {boolean} True if path is within allowed roots
 */
function isPathAllowed(resolvedPath) {
  const normalizedPath = path.normalize(resolvedPath);
  
  return allowedRoots.some(root => {
    const normalizedRoot = path.normalize(root);
    // Check if path starts with root and is properly contained
    return normalizedPath.startsWith(normalizedRoot) &&
           (normalizedPath === normalizedRoot ||
            normalizedPath.startsWith(normalizedRoot + path.sep));
  });
}

/**
 * Detect directory traversal attempts
 * @param {string} requestPath - Original requested path
 * @returns {boolean} True if path contains traversal attempts
 */
function hasDirectoryTraversal(requestPath) {
  // Check for various directory traversal patterns
  const traversalPatterns = [
    /\.\./,           // Standard .. traversal
    /\.\.[\\/]/,      // .. with separators
    /[\\/]\.\./,      // .. after separators
    /%2e%2e/i,        // URL encoded ..
    /\.%2f/i,         // Mixed encoding
    /\.\.\\/,         // Windows style
    /\.\.\//          // Unix style
  ];
  
  return traversalPatterns.some(pattern => pattern.test(requestPath));
}

/**
 * Synchronously reads a file and returns its content as UTF-8 text
 *
 * @param {string} requestPath - The file path to read (relative or absolute)
 * @param {string} cwd - Current working directory for resolving relative paths
 * @returns {string} File content as UTF-8 text
 * @throws {Error} If path is invalid, not allowed, or file cannot be read
 */
function hostLoadFileSync(requestPath, cwd = process.cwd()) {
  // Validate input
  if (typeof requestPath !== "string" || requestPath.length === 0) {
    throw new Error("host-load-file: path must be a non-empty string");
  }
  
  // Check for directory traversal attempts
  if (hasDirectoryTraversal(requestPath)) {
    throw new Error(`host-load-file: Directory traversal detected in path '${requestPath}'`);
  }
  
  // Resolve relative paths safely
  const resolvedPath = path.isAbsolute(requestPath)
    ? path.resolve(requestPath)
    : path.resolve(cwd, requestPath);
  
  // Check if resolved path is within allowed roots
  if (!isPathAllowed(resolvedPath)) {
    throw new Error(`host-load-file: Access denied to path '${requestPath}' (resolved: '${resolvedPath}')`);
  }
  
  // Additional security: ensure the resolved path doesn't contain traversal
  if (hasDirectoryTraversal(resolvedPath)) {
    throw new Error(`host-load-file: Directory traversal detected in resolved path '${resolvedPath}'`);
  }
  
  // Read file as UTF-8 text
  try {
    return fs.readFileSync(resolvedPath, "utf8");
  } catch (error) {
    // Re-throw with more context
    throw new Error(`host-load-file: Cannot read file '${requestPath}': ${error.message}`);
  }
}

module.exports = {
  hostLoadFileSync,
  setAllowedRoots,
  getAllowedRoots,
  isPathAllowed,
  hasDirectoryTraversal,
  DEFAULT_ALLOWED_ROOTS
};