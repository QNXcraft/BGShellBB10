#!/bin/bash
# Build script for BGShellBB10
# This script can be used locally or in CI/CD environments

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if BB10 NDK is available
check_ndk() {
    if [ -z "$QNX_HOST" ] || [ -z "$QNX_TARGET" ]; then
        print_warning "BB10 NDK environment not configured"
        
        # Try to source common NDK locations
        if [ -f ~/bbndk/bbndk-env.sh ]; then
            print_info "Found NDK at ~/bbndk, sourcing environment..."
            source ~/bbndk/bbndk-env.sh
        elif [ -f /opt/bbndk/bbndk-env.sh ]; then
            print_info "Found NDK at /opt/bbndk, sourcing environment..."
            source /opt/bbndk/bbndk-env.sh
        else
            print_error "BB10 NDK not found. Please install and source bbndk-env.sh"
            print_error "Or set QNX_HOST and QNX_TARGET environment variables"
            exit 1
        fi
    fi
    
    print_info "BB10 NDK configured:"
    print_info "  QNX_HOST: $QNX_HOST"
    print_info "  QNX_TARGET: $QNX_TARGET"
}

# Prepare build files (copy from underscored versions)
prepare_files() {
    print_info "Preparing build files..."
    
    if [ -f "_BGShellBB10.pro" ]; then
        cp _BGShellBB10.pro BGShellBB10.pro
        print_info "  Copied BGShellBB10.pro"
    fi
    
    if [ -f "_bar-descriptor.xml" ]; then
        cp _bar-descriptor.xml bar-descriptor.xml
        print_info "  Copied bar-descriptor.xml"
    fi
    
    if [ -f "_Makefile" ]; then
        cp _Makefile Makefile
        print_info "  Copied Makefile"
    fi
}

# Clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."
    
    if [ -f "Makefile" ]; then
        make clean 2>/dev/null || true
    fi
    
    rm -rf arm x86 *.bar
    print_info "Clean complete"
}

# Build for device (release)
build_device_release() {
    print_info "Building Device-Release..."
    make Device-Release
    
    print_info "Creating Device-Release BAR package..."
    make Device-Release.bar
    
    if [ -f "Device-Release.bar" ]; then
        print_info "${GREEN}Build successful!${NC}"
        ls -lh Device-Release.bar
    else
        print_error "Build failed - Device-Release.bar not created"
        exit 1
    fi
}

# Build for device (debug)
build_device_debug() {
    print_info "Building Device-Debug..."
    make Device-Debug
    
    print_info "Creating Device-Debug BAR package..."
    make Device-Debug.bar
    
    if [ -f "Device-Debug.bar" ]; then
        print_info "${GREEN}Build successful!${NC}"
        ls -lh Device-Debug.bar
    else
        print_error "Build failed - Device-Debug.bar not created"
        exit 1
    fi
}

# Build for simulator
build_simulator() {
    print_info "Building Simulator-Debug..."
    make Simulator-Debug
    
    print_info "Creating Simulator-Debug BAR package..."
    make Simulator-Debug.bar
    
    if [ -f "Simulator-Debug.bar" ]; then
        print_info "${GREEN}Build successful!${NC}"
        ls -lh Simulator-Debug.bar
    else
        print_error "Build failed - Simulator-Debug.bar not created"
        exit 1
    fi
}

# Main script
main() {
    print_info "BGShellBB10 Build Script"
    print_info "========================"
    echo
    
    # Parse command line arguments
    BUILD_TYPE="${1:-release}"
    
    case "$BUILD_TYPE" in
        clean)
            prepare_files
            clean_build
            ;;
        debug)
            check_ndk
            prepare_files
            build_device_debug
            ;;
        simulator)
            check_ndk
            prepare_files
            build_simulator
            ;;
        release)
            check_ndk
            prepare_files
            build_device_release
            ;;
        all)
            check_ndk
            prepare_files
            build_device_release
            build_device_debug
            build_simulator
            ;;
        *)
            echo "Usage: $0 [clean|debug|release|simulator|all]"
            echo
            echo "Options:"
            echo "  clean     - Clean build artifacts"
            echo "  debug     - Build device debug version"
            echo "  release   - Build device release version (default)"
            echo "  simulator - Build simulator version"
            echo "  all       - Build all versions"
            exit 1
            ;;
    esac
    
    echo
    print_info "Done!"
}

# Run main function
main "$@"
