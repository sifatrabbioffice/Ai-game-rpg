#!/bin/bash

# iOS RPG Game Build Script
# Usage: ./build.sh [--release] [--sideload] [--clean] [--test]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
CONFIG="Debug"
SHOULD_SIDELOAD=false
SHOULD_CLEAN=false
SHOULD_TEST=false
SCHEME="RPGGame"
DERIVED_DATA_PATH="build"
XCODE_PROJECT="RPGGame.xcodeproj"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIG="Release"
            shift
            ;;
        --sideload)
            SHOULD_SIDELOAD=true
            shift
            ;;
        --clean)
            SHOULD_CLEAN=true
            shift
            ;;
        --test)
            SHOULD_TEST=true
            shift
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Functions
print_help() {
    echo "Usage: ./build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --release       Build in Release configuration"
    echo "  --sideload      Create IPA for sideloading"
    echo "  --clean         Clean build artifacts first"
    echo "  --test          Run tests after building"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh                    # Debug build"
    echo "  ./build.sh --release          # Release build"
    echo "  ./build.sh --release --test   # Release build with tests"
}

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

check_xcode() {
    print_step "Checking Xcode installation..."
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed. Please install Xcode from the App Store."
        exit 1
    fi
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_success "$XCODE_VERSION"
}

check_project() {
    print_step "Checking project files..."
    if [ ! -f "$XCODE_PROJECT" ]; then
        print_error "Xcode project not found: $XCODE_PROJECT"
        exit 1
    fi
    print_success "Project found: $XCODE_PROJECT"
}

clean_build() {
    if [ "$SHOULD_CLEAN" = true ]; then
        print_step "Cleaning build artifacts..."
        rm -rf "$DERIVED_DATA_PATH"
        rm -rf build.log
        print_success "Build artifacts cleaned"
    fi
}

build_app() {
    print_step "Building $SCHEME ($CONFIG)..."
    
    xcodebuild \
        -scheme "$SCHEME" \
        -configuration "$CONFIG" \
        -sdk iphoneos \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -verbose \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | tee build.log
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed. Check build.log for details."
        exit 1
    fi
}

run_tests() {
    if [ "$SHOULD_TEST" = true ]; then
        print_step "Running tests..."
        
        xcodebuild \
            -scheme "$SCHEME" \
            -configuration Debug \
            -sdk iphonesimulator \
            -derivedDataPath "$DERIVED_DATA_PATH" \
            test \
            -verbose
        
        if [ $? -eq 0 ]; then
            print_success "All tests passed"
        else
            print_error "Tests failed"
            exit 1
        fi
    fi
}

create_archive() {
    print_step "Creating archive..."
    
    xcodebuild \
        -scheme "$SCHEME" \
        -configuration Release \
        -sdk iphoneos \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -archivePath "$DERIVED_DATA_PATH/$SCHEME.xcarchive" \
        archive \
        -verbose \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO
    
    if [ $? -eq 0 ]; then
        print_success "Archive created"
    else
        print_error "Failed to create archive"
        exit 1
    fi
}

create_ipa() {
    if [ "$SHOULD_SIDELOAD" = true ]; then
        print_step "Creating IPA for sideloading..."
        
        mkdir -p "$DERIVED_DATA_PATH/ipa"
        
        # Extract app from archive
        APP_PATH="$DERIVED_DATA_PATH/$SCHEME.xcarchive/Products/Applications/$SCHEME.app"
        
        if [ ! -d "$APP_PATH" ]; then
            print_error "App bundle not found in archive"
            exit 1
        fi
        
        # Create Payload directory
        mkdir -p "$DERIVED_DATA_PATH/Payload"
        cp -r "$APP_PATH" "$DERIVED_DATA_PATH/Payload/"
        
        # Create IPA (which is just a zip file)
        cd "$DERIVED_DATA_PATH"
        zip -r -q "$SCHEME-sideload.ipa" Payload/
        cd - > /dev/null
        
        print_success "IPA created: $DERIVED_DATA_PATH/$SCHEME-sideload.ipa"
        print_warning "IPA size: $(du -h "$DERIVED_DATA_PATH/$SCHEME-sideload.ipa" | cut -f1)"
    fi
}

print_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}Build Summary${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo "Configuration: $CONFIG"
    echo "Scheme: $SCHEME"
    echo "Derived Data: $DERIVED_DATA_PATH"
    
    if [ "$SHOULD_TEST" = true ]; then
        echo "Tests: ✓ Passed"
    fi
    
    if [ "$SHOULD_SIDELOAD" = true ] && [ -f "$DERIVED_DATA_PATH/$SCHEME-sideload.ipa" ]; then
        echo "IPA: ✓ Created"
        echo "Location: $DERIVED_DATA_PATH/$SCHEME-sideload.ipa"
        echo ""
        echo "Next steps for sideloading:"
        echo "  1. Download AltStore from https://altstore.io/"
        echo "  2. Connect your iPhone"
        echo "  3. Open AltStore and click 'Install IPA'"
        echo "  4. Select: $DERIVED_DATA_PATH/$SCHEME-sideload.ipa"
        echo "  5. Trust the developer on your device"
    fi
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   iOS RPG Game Build Script           ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_xcode
    check_project
    clean_build
    build_app
    run_tests
    
    if [ "$CONFIG" = "Release" ]; then
        create_archive
        create_ipa
    fi
    
    print_summary
}

# Run main function
main
