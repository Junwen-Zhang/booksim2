#!/bin/bash
#
# Integration script for BookSim2 into SST-Elements
# This script helps automate the process of registering BookSim2 as an SST-Elements module
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to print usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -s, --sst-elements PATH    Path to SST-Elements source directory (required)
    -h, --help                 Display this help message

Description:
    This script integrates BookSim2 into SST-Elements by:
    1. Copying BookSim2 source to SST-Elements
    2. Updating SST-Elements configuration files
    3. Providing instructions for building

Example:
    $0 --sst-elements /path/to/sst-elements

EOF
}

# Parse command line arguments
SST_ELEMENTS_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--sst-elements)
            SST_ELEMENTS_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate arguments
if [ -z "$SST_ELEMENTS_PATH" ]; then
    print_error "SST-Elements path is required"
    usage
    exit 1
fi

if [ ! -d "$SST_ELEMENTS_PATH" ]; then
    print_error "SST-Elements directory does not exist: $SST_ELEMENTS_PATH"
    exit 1
fi

# Get the directory where this script is located (BookSim2 root)
BOOKSIM2_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_info "BookSim2 source directory: $BOOKSIM2_PATH"
print_info "SST-Elements directory: $SST_ELEMENTS_PATH"

# Step 1: Copy BookSim2 to SST-Elements
DEST_PATH="$SST_ELEMENTS_PATH/src/sst/elements/booksim2"

print_info "Checking if destination directory exists..."
if [ -d "$DEST_PATH" ]; then
    print_warning "Destination directory already exists: $DEST_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Aborted by user"
        exit 0
    fi
    print_info "Removing existing directory..."
    rm -rf "$DEST_PATH"
fi

print_info "Copying BookSim2 source to SST-Elements..."
mkdir -p "$DEST_PATH"
cp -r "$BOOKSIM2_PATH"/* "$DEST_PATH/"

# Remove unnecessary files
print_info "Cleaning up destination directory..."
rm -f "$DEST_PATH/integrate_sst.sh"
rm -rf "$DEST_PATH/.git"

# Step 2: Update configure.ac
CONFIGURE_AC="$SST_ELEMENTS_PATH/configure.ac"
print_info "Updating configure.ac..."

if [ ! -f "$CONFIGURE_AC" ]; then
    print_error "configure.ac not found in SST-Elements directory"
    exit 1
fi

# Check if booksim2 is already registered
if grep -q "SST_CHECK_ELEMENT.*booksim2" "$CONFIGURE_AC"; then
    print_warning "BookSim2 already registered in configure.ac"
else
    # Create backup
    cp "$CONFIGURE_AC" "$CONFIGURE_AC.bak"
    print_info "Created backup: $CONFIGURE_AC.bak"
    
    # Add SST_CHECK_ELEMENT for booksim2
    # We'll add it before the last occurrence of SST_CHECK_ELEMENT or at the end of the checks section
    if grep -q "SST_CHECK_ELEMENT" "$CONFIGURE_AC"; then
        # Find the last SST_CHECK_ELEMENT line and add after it
        last_check_line=$(grep -n "SST_CHECK_ELEMENT" "$CONFIGURE_AC" | tail -1 | cut -d: -f1)
        sed -i "${last_check_line}a SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])" "$CONFIGURE_AC"
        print_info "Added SST_CHECK_ELEMENT for booksim2"
    else
        print_warning "Could not find SST_CHECK_ELEMENT entries. You may need to manually add:"
        echo "SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])"
    fi
fi

# Add AC_CONFIG_FILES entry
if grep -q "src/sst/elements/booksim2/Makefile" "$CONFIGURE_AC"; then
    print_warning "Makefile entry already exists in AC_CONFIG_FILES"
else
    if grep -q "AC_CONFIG_FILES" "$CONFIGURE_AC"; then
        # Find AC_CONFIG_FILES section and add our Makefile
        # This is a simple approach - in practice, you might need to adjust based on actual file structure
        sed -i '/AC_CONFIG_FILES/a \    src/sst/elements/booksim2/Makefile' "$CONFIGURE_AC"
        print_info "Added Makefile to AC_CONFIG_FILES"
    else
        print_warning "Could not find AC_CONFIG_FILES. You may need to manually add:"
        echo "src/sst/elements/booksim2/Makefile"
    fi
fi

# Step 3: Update src/sst/elements/Makefile.am
ELEMENTS_MAKEFILE="$SST_ELEMENTS_PATH/src/sst/elements/Makefile.am"
print_info "Updating elements Makefile.am..."

if [ ! -f "$ELEMENTS_MAKEFILE" ]; then
    print_error "Makefile.am not found in src/sst/elements/"
    exit 1
fi

if grep -q "booksim2" "$ELEMENTS_MAKEFILE"; then
    print_warning "booksim2 already in Makefile.am"
else
    # Create backup
    cp "$ELEMENTS_MAKEFILE" "$ELEMENTS_MAKEFILE.bak"
    print_info "Created backup: $ELEMENTS_MAKEFILE.bak"
    
    # Add booksim2 to SUBDIRS
    if grep -q "^SUBDIRS" "$ELEMENTS_MAKEFILE"; then
        # Add booksim2 to the SUBDIRS list
        sed -i '/^SUBDIRS/a \    booksim2 \\' "$ELEMENTS_MAKEFILE"
        print_info "Added booksim2 to SUBDIRS"
    else
        print_warning "Could not find SUBDIRS in Makefile.am. You may need to manually add booksim2"
    fi
fi

# Step 4: Print next steps
print_info ""
print_info "========================================"
print_info "BookSim2 Integration Complete!"
print_info "========================================"
print_info ""
print_info "Next steps:"
print_info "1. Review the changes made to:"
print_info "   - $CONFIGURE_AC"
print_info "   - $ELEMENTS_MAKEFILE"
print_info ""
print_info "2. Rebuild SST-Elements:"
print_info "   cd $SST_ELEMENTS_PATH"
print_info "   ./autogen.sh"
print_info "   ./configure --prefix=/path/to/install"
print_info "   make -j\$(nproc)"
print_info "   make install"
print_info ""
print_info "3. Verify the installation:"
print_info "   sst-info booksim2"
print_info ""
print_info "For more detailed information, see:"
print_info "   $DEST_PATH/INTEGRATION.md"
print_info ""
print_info "Backups created:"
print_info "   - $CONFIGURE_AC.bak"
print_info "   - $ELEMENTS_MAKEFILE.bak"
print_info ""
