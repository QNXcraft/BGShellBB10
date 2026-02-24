#!/bin/bash
# Build script for BGShellBB10
# Uses Docker container with BB10 NDK for consistent builds

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Docker image with BB10 NDK
DOCKER_IMAGE="sw7ft/bb10-gcc9:latest"

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

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found. Please install Docker to use this build script."
        print_info "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    print_info "Docker found: $(docker --version)"
}

# Pull the BB10 build image
pull_image() {
    print_info "Pulling BB10 Docker image: $DOCKER_IMAGE"
    docker pull "$DOCKER_IMAGE"
}

# Prepare build files (copy from underscored versions)
prepare_files() {
    print_info "Preparing build files..."
    
    if [ -f "_BGShellBB10.pro" ]; then
        cp _BGShellBB10.pro BGShellBB10.pro
        print_info "  ✓ Copied BGShellBB10.pro"
    fi
    
    if [ -f "_bar-descriptor.xml" ]; then
        cp _bar-descriptor.xml bar-descriptor.xml
        print_info "  ✓ Copied bar-descriptor.xml"
    fi
    
    if [ -f "_Makefile" ]; then
        cp _Makefile Makefile
        print_info "  ✓ Copied Makefile"
    fi
}

# Clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."
    
    docker run --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        bash -c "source /root/bbndk/bbndk-env_10_3_1_995.sh && export LC_ALL=C && make clean 2>/dev/null || true"
    
    rm -rf arm x86 *.bar 2>/dev/null || true
    print_info "✓ Clean complete"
}

# Build for device (release)
build_device_release() {
    print_header "============================================"
    print_header "Building Device-Release"
    print_header "============================================"
    
    docker run --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        bash -c "source /root/bbndk/bbndk-env_10_3_1_995.sh && \
                 export LC_ALL=C && \
                 make Device-Release && \
                 make Device-Release.bar"
    
    if [ -f "Device-Release.bar" ]; then
        print_info "${GREEN}✓ Build successful!${NC}"
        echo ""
        print_info "Build artifacts:"
        ls -lh Device-Release.bar
        ls -lh arm/o.le-v7/BGShellBB10 2>/dev/null || true
    else
        print_error "Build failed - Device-Release.bar not created"
        exit 1
    fi
}

# Build for device (debug)
build_device_debug() {
    print_header "============================================"
    print_header "Building Device-Debug"
    print_header "============================================"
    
    docker run --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        bash -c "source /root/bbndk/bbndk-env_10_3_1_995.sh && \
                 export LC_ALL=C && \
                 make Device-Debug && \
                 make Device-Debug.bar"
    
    if [ -f "Device-Debug.bar" ]; then
        print_info "${GREEN}✓ Build successful!${NC}"
        echo ""
        print_info "Build artifacts:"
        ls -lh Device-Debug.bar
    else
        print_error "Build failed - Device-Debug.bar not created"
        exit 1
    fi
}

# Build for simulator
build_simulator() {
    print_header "============================================"
    print_header "Building Simulator-Debug"
    print_header "============================================"
    
    docker run --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        bash -c "source /root/bbndk/bbndk-env_10_3_1_995.sh && \
                 export LC_ALL=C && \
                 make Simulator-Debug && \
                 make Simulator-Debug.bar"
    
    if [ -f "Simulator-Debug.bar" ]; then
        print_info "${GREEN}✓ Build successful!${NC}"
        echo ""
        print_info "Build artifacts:"
        ls -lh Simulator-Debug.bar
    else
        print_error "Build failed - Simulator-Debug.bar not created"
        exit 1
    fi
}

# Main script
main() {
    print_header "============================================"
    print_header "BGShellBB10 Docker Build Script"
    print_header "============================================"
    echo
    
    # Parse command line arguments
    BUILD_TYPE="${1:-release}"
    
    case "$BUILD_TYPE" in
        clean)
            check_docker
            prepare_files
            clean_build
            ;;
        debug)
            check_docker
            pull_image
            prepare_files
            build_device_debug
            ;;
        simulator)
            check_docker
            pull_image
            prepare_files
            build_simulator
            ;;
        release)
            check_docker
            pull_image
            prepare_files
            build_device_release
            ;;
        all)
            check_docker
            pull_image
            prepare_files
            build_device_release
            build_device_debug
            build_simulator
            ;;
        *)
            echo "Usage: $0 [clean|debug|release|simulator|all]"
            echo ""
            echo "Options:"
            echo "  clean     - Clean build artifacts"
            echo "  debug     - Build device debug version"
            echo "  release   - Build device release version (default)"
            echo "  simulator - Build simulator version"
            echo "  all       - Build all versions"
            echo ""
            echo "Requirements:"
            echo "  - Docker must be installed"
            echo "  - Internet connection (to pull Docker image)"
            exit 1
            ;;
    esac
    
    echo ""
    print_info "Done!"
}

# Run main function
main "$@"
