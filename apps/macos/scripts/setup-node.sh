#!/bin/bash

# Exit on any error
set -e

# Set up paths
RESOURCES_DIR="$1/Contents/Resources"
NODE_DIR="$RESOURCES_DIR/node"

echo "🔧 Setting up Node.js environment..."
echo "Configuration: $CONFIGURATION"
echo "Resources directory: $RESOURCES_DIR"

# Clean up existing node directory
rm -rf "$NODE_DIR"
mkdir -p "$NODE_DIR"

# Determine platform
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    PLATFORM="darwin-arm64"
else
    PLATFORM="darwin-x64"
fi

if [ "$CONFIGURATION" = "Debug" ]; then
    echo "Debug build: Creating symlinks to system Node.js..."
    
    # Check if node and npm are installed
    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        echo "❌ Node.js and npm are required for development. Please install them using:"
        echo "brew install node"
        exit 1
    fi
    
    # Get the actual paths instead of symlinks
    NODE_PATH=$(which node)
    NPM_PATH=$(which npm)
    
    echo "Found Node.js at: $NODE_PATH"
    echo "Found npm at: $NPM_PATH"
    
    # Create bin directory and symlinks
    mkdir -p "$NODE_DIR/bin"
    ln -sf "$NODE_PATH" "$NODE_DIR/bin/node"
    ln -sf "$NPM_PATH" "$NODE_DIR/bin/npm"
    
    # Install sharp locally for development
    echo "Installing sharp locally..."
    mkdir -p "$NODE_DIR"
    cd "$NODE_DIR"
    
    # Create package.json
    cat > "package.json" << EOF
{
  "name": "drag-n-convert-deps",
  "version": "1.0.0",
  "dependencies": {
    "sharp": "^0.33.2"
  }
}
EOF
    
    # Install sharp locally
    npm install --production
else
    echo "Release build: Downloading Node.js..."
    NODE_VERSION="20.11.1"
    NODE_URL="https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-$PLATFORM.tar.gz"
    
    curl -L "$NODE_URL" | tar xz -C "$NODE_DIR" --strip-components=1
    
    # Set up npm and install sharp
    echo "Installing sharp..."
    export PATH="$NODE_DIR/bin:$PATH"
    export npm_config_prefix="$NODE_DIR"
    
    cd "$NODE_DIR"
    ./bin/npm install sharp --production
fi

# Copy the image processor script
cp "$SRCROOT/scripts/image-processor.js" "$RESOURCES_DIR/"

# Verify the setup
echo "📂 Verifying setup..."
echo "Node.js version:"
"$NODE_DIR/bin/node" --version
echo "npm version:"
"$NODE_DIR/bin/npm" --version

echo "📂 Contents of node directory:"
ls -la "$NODE_DIR"
echo "📂 Contents of node_modules:"
ls -la "$NODE_DIR/node_modules"
echo "📂 Contents of Resources directory:"
ls -la "$RESOURCES_DIR"

# Verify sharp installation
if [ -d "$NODE_DIR/node_modules/sharp" ]; then
    echo "✅ sharp module installed successfully"
else
    echo "❌ sharp module not found!"
    exit 1
fi

echo "✅ Node.js environment setup complete" 