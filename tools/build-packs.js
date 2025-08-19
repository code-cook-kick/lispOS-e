#!/usr/bin/env node
// Build and package legal knowledge packs

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class PackBuilder {
    constructor() {
        this.buildDir = 'dist';
        this.packagesDir = path.join(this.buildDir, 'packages');
    }

    async build(packDir) {
        const manifestPath = path.join(packDir, 'manifest.json');
        
        if (!fs.existsSync(manifestPath)) {
            throw new Error(`No manifest.json found in ${packDir}`);
        }

        const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
        
        // Create build directory
        if (!fs.existsSync(this.buildDir)) {
            fs.mkdirSync(this.buildDir, { recursive: true });
        }
        
        if (!fs.existsSync(this.packagesDir)) {
            fs.mkdirSync(this.packagesDir, { recursive: true });
        }

        // Build package
        const packageInfo = await this.buildPackage(packDir, manifest);
        
        console.log(`✅ Built package: ${packageInfo.filename}`);
        return packageInfo;
    }

    async buildPackage(packDir, manifest) {
        const packageName = `${manifest.id}-${manifest.version}`;
        const packageDir = path.join(this.packagesDir, packageName);
        
        // Clean and create package directory
        if (fs.existsSync(packageDir)) {
            fs.rmSync(packageDir, { recursive: true });
        }
        fs.mkdirSync(packageDir, { recursive: true });

        // Copy essential files
        const filesToCopy = [
            'manifest.json',
            'README.md',
            'main.ether',
            'CHANGELOG.md'
        ];

        for (const file of filesToCopy) {
            const srcPath = path.join(packDir, file);
            const destPath = path.join(packageDir, file);
            
            if (fs.existsSync(srcPath)) {
                fs.copyFileSync(srcPath, destPath);
            }
        }

        // Copy optional files
        const optionalFiles = ['facts.example.ether'];
        for (const file of optionalFiles) {
            const srcPath = path.join(packDir, file);
            const destPath = path.join(packageDir, file);
            
            if (fs.existsSync(srcPath)) {
                fs.copyFileSync(srcPath, destPath);
            }
        }

        // Copy tests directory
        const testsDir = path.join(packDir, 'tests');
        if (fs.existsSync(testsDir)) {
            const destTestsDir = path.join(packageDir, 'tests');
            this.copyDirectory(testsDir, destTestsDir);
        }

        // Compute integrity hash
        const hash = await this.computePackageHash(packageDir);
        
        // Update manifest with integrity hash
        const updatedManifest = {
            ...manifest,
            integrity: {
                hash: hash,
                algo: 'sha256'
            }
        };
        
        fs.writeFileSync(
            path.join(packageDir, 'manifest.json'),
            JSON.stringify(updatedManifest, null, 2)
        );

        // Create tarball
        const tarballPath = path.join(this.packagesDir, `${packageName}.tar.gz`);
        await this.createTarball(packageDir, tarballPath);

        // Generate package info
        const stats = fs.statSync(tarballPath);
        const packageInfo = {
            id: manifest.id,
            version: manifest.version,
            filename: path.basename(tarballPath),
            size: stats.size,
            hash: hash,
            buildTime: new Date().toISOString(),
            files: this.listPackageFiles(packageDir)
        };

        // Write package info
        fs.writeFileSync(
            path.join(this.packagesDir, `${packageName}.json`),
            JSON.stringify(packageInfo, null, 2)
        );

        return packageInfo;
    }

    copyDirectory(src, dest) {
        if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest, { recursive: true });
        }

        const entries = fs.readdirSync(src, { withFileTypes: true });
        
        for (const entry of entries) {
            const srcPath = path.join(src, entry.name);
            const destPath = path.join(dest, entry.name);
            
            if (entry.isDirectory()) {
                this.copyDirectory(srcPath, destPath);
            } else {
                fs.copyFileSync(srcPath, destPath);
            }
        }
    }

    async computePackageHash(packageDir) {
        const hash = crypto.createHash('sha256');
        
        // Get all files in sorted order for deterministic hash
        const files = this.getAllFiles(packageDir).sort();
        
        for (const file of files) {
            const relativePath = path.relative(packageDir, file);
            const content = fs.readFileSync(file);
            
            hash.update(relativePath);
            hash.update(content);
        }
        
        return hash.digest('hex');
    }

    getAllFiles(dir) {
        const files = [];
        
        function traverse(currentDir) {
            const entries = fs.readdirSync(currentDir, { withFileTypes: true });
            
            for (const entry of entries) {
                const fullPath = path.join(currentDir, entry.name);
                
                if (entry.isDirectory()) {
                    traverse(fullPath);
                } else {
                    files.push(fullPath);
                }
            }
        }
        
        traverse(dir);
        return files;
    }

    listPackageFiles(packageDir) {
        const files = this.getAllFiles(packageDir);
        return files.map(file => {
            const relativePath = path.relative(packageDir, file);
            const stats = fs.statSync(file);
            return {
                path: relativePath,
                size: stats.size
            };
        });
    }

    async createTarball(sourceDir, outputPath) {
        // Simple tarball creation using tar command
        const { spawn } = require('child_process');
        
        return new Promise((resolve, reject) => {
            const tar = spawn('tar', [
                '-czf',
                outputPath,
                '-C',
                path.dirname(sourceDir),
                path.basename(sourceDir)
            ]);
            
            tar.on('close', (code) => {
                if (code === 0) {
                    resolve();
                } else {
                    reject(new Error(`tar process exited with code ${code}`));
                }
            });
            
            tar.on('error', reject);
        });
    }

    async buildAll(baseDir = 'packs/legal') {
        const packs = this.findPacks(baseDir);
        const results = [];
        
        console.log(`Building ${packs.length} packs...`);
        
        for (const pack of packs) {
            try {
                const result = await this.build(pack);
                results.push(result);
            } catch (error) {
                console.error(`❌ Failed to build ${pack}: ${error.message}`);
                results.push({
                    pack: pack,
                    error: error.message
                });
            }
        }
        
        // Generate build manifest
        const buildManifest = {
            buildTime: new Date().toISOString(),
            totalPacks: packs.length,
            successfulBuilds: results.filter(r => !r.error).length,
            failedBuilds: results.filter(r => r.error).length,
            packages: results
        };
        
        fs.writeFileSync(
            path.join(this.buildDir, 'build-manifest.json'),
            JSON.stringify(buildManifest, null, 2)
        );
        
        console.log(`\nBuild complete: ${buildManifest.successfulBuilds}/${buildManifest.totalPacks} successful`);
        
        return buildManifest;
    }

    findPacks(baseDir) {
        const packs = [];
        
        function traverse(dir) {
            if (!fs.existsSync(dir)) return;
            
            const entries = fs.readdirSync(dir, { withFileTypes: true });
            
            // Check if this directory is a pack (has manifest.json)
            if (entries.some(e => e.name === 'manifest.json')) {
                packs.push(dir);
                return;
            }
            
            // Recurse into subdirectories
            for (const entry of entries) {
                if (entry.isDirectory()) {
                    traverse(path.join(dir, entry.name));
                }
            }
        }
        
        traverse(baseDir);
        return packs;
    }
}

function main() {
    const args = process.argv.slice(2);
    const builder = new PackBuilder();
    
    if (args.length === 0) {
        // Build all packs
        builder.buildAll().catch(error => {
            console.error('Build failed:', error);
            process.exit(1);
        });
    } else {
        // Build specific pack
        const packDir = args[0];
        builder.build(packDir).catch(error => {
            console.error('Build failed:', error);
            process.exit(1);
        });
    }
}

if (require.main === module) {
    main();
}

module.exports = { PackBuilder };