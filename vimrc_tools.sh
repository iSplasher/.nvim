#!/bin/bash

# vimrc_tools.sh
# Automation tools for generating and managing .vimrc from Neovim configuration
# Usage: ./vimrc_tools.sh [command]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC_FILE="$SCRIPT_DIR/.vimrc"
# No longer needed - using Neovim introspection

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# No longer needed - using Neovim introspection

# Generate .vimrc using Neovim introspection
generate_vimrc() {
    log_info "Generating .vimrc from current Neovim configuration..."

    cd "$SCRIPT_DIR"

    # Use direct Lua script to export the configuration
    log_info "Running: nvim --headless -l export_vimrc_direct.lua $VIMRC_FILE"
    local nvim_output
    nvim_output=$(nvim --headless -l export_vimrc_direct.lua "$VIMRC_FILE" 2>&1)
    local nvim_exit_code=$?

    if [[ -f "$VIMRC_FILE" ]]; then
        log_success "Generated .vimrc from Neovim session!"
        local line_count=$(wc -l <"$VIMRC_FILE")
        log_info "Lines written: $line_count"
        
        # Show any warnings or info from Neovim
        if [[ -n "$nvim_output" ]]; then
            log_info "Neovim output:"
            echo "$nvim_output"
        fi
    else
        log_error "Failed to generate .vimrc from Neovim"
        log_error "Exit code: $nvim_exit_code"
        if [[ -n "$nvim_output" ]]; then
            log_error "Neovim output:"
            echo "$nvim_output"
        fi
        exit 1
    fi
}

# Test the generated .vimrc
test_vimrc() {
    log_info "Testing generated .vimrc..."

    if [[ ! -f "$VIMRC_FILE" ]]; then
        log_error ".vimrc not found. Generate it first."
        exit 1
    fi

    # Check if vim is available
    if ! command -v vim >/dev/null 2>&1; then
        log_warning "vim is not installed, cannot test .vimrc"
        log_info "The .vimrc file exists and appears to be generated correctly"
        return 0
    fi

    # Test vim syntax by checking for basic syntax errors
    log_info "Checking vim syntax..."

    # Create a minimal test that won't trigger vim-plug
    local test_output
    test_output=$(vim -e -s -c "syntax off" -c "source $VIMRC_FILE" -c "qa!" 2>&1 || true)

    # Check for actual syntax errors (not vim-plug curl errors)
    if echo "$test_output" | grep -E "(Error|Invalid|Unknown)" | grep -v "curl.*no URL specified" | grep -v "vim-plug" >/dev/null; then
        log_error ".vimrc contains syntax errors"
        log_info "Error details:"
        echo "$test_output" | grep -E "(Error|Invalid|Unknown)" | grep -v curl
        return 1
    else
        log_success ".vimrc syntax appears valid"
        if echo "$test_output" | grep -q "curl.*no URL specified"; then
            log_info "(vim-plug installation attempt is normal)"
        fi
    fi

    # Check for common issues
    log_info "Checking for common issues..."

    local issues=0

    # Check for duplicate leader definitions
    local leader_count=$(grep -c "let.*leader" "$VIMRC_FILE" || true)
    if [[ $leader_count -gt 2 ]]; then
        log_warning "Multiple leader key definitions found ($leader_count)"
        ((issues++))
    fi

    # Check for basic sections
    local required_sections=("BASIC SETTINGS" "KEYMAPS" "PLUGIN MANAGEMENT")
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" "$VIMRC_FILE"; then
            log_warning "Missing section: $section"
            ((issues++))
        fi
    done

    if [[ $issues -eq 0 ]]; then
        log_success "No issues found in .vimrc"
    else
        log_warning "Found $issues potential issues"
    fi
}

# Install .vimrc to home directory
install_vimrc() {
    local target="$HOME/.vimrc"

    if [[ ! -f "$VIMRC_FILE" ]]; then
        log_error ".vimrc not found. Generate it first."
        exit 1
    fi

    # Backup existing vimrc
    if [[ -f "$target" ]]; then
        local backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $target to $backup"
        cp "$target" "$backup"
    fi

    # Install new vimrc
    cp "$VIMRC_FILE" "$target"
    log_success "Installed $target successfully!"
    log_info "You can now use vim with your Neovim-derived configuration."
}

# Compare with existing .vimrc
compare_vimrc() {
    local target="$HOME/.vimrc"

    if [[ ! -f "$VIMRC_FILE" ]]; then
        log_error "Generated .vimrc not found. Generate it first."
        exit 1
    fi

    if [[ ! -f "$target" ]]; then
        log_info "No existing ~/.vimrc found to compare with"
        return 0
    fi

    log_info "Comparing generated .vimrc with existing ~/.vimrc..."

    if command -v diff >/dev/null 2>&1; then
        if diff -q "$VIMRC_FILE" "$target" >/dev/null; then
            log_success "Generated .vimrc is identical to existing ~/.vimrc"
        else
            log_info "Differences found between generated and existing .vimrc:"
            diff "$VIMRC_FILE" "$target" || true
        fi
    else
        log_warning "diff command not available, cannot compare files"
    fi
}

# Show statistics about the generated .vimrc
stats_vimrc() {
    if [[ ! -f "$VIMRC_FILE" ]]; then
        log_error ".vimrc not found. Generate it first."
        exit 1
    fi

    log_info "Statistics for generated .vimrc:"

    local total_lines=$(wc -l <"$VIMRC_FILE")
    local comment_lines=$(grep -c "^[[:space:]]*\"" "$VIMRC_FILE" || true)
    local empty_lines=$(grep -c "^[[:space:]]*$" "$VIMRC_FILE" || true)
    local config_lines=$((total_lines - comment_lines - empty_lines))

    echo "  Total lines: $total_lines"
    echo "  Comment lines: $comment_lines"
    echo "  Empty lines: $empty_lines"
    echo "  Configuration lines: $config_lines"

    # Count mappings
    local mappings=$(grep -c "noremap\|map" "$VIMRC_FILE" || true)
    echo "  Key mappings: $mappings"

    # Count settings
    local settings=$(grep -c "^set " "$VIMRC_FILE" || true)
    echo "  Vim settings: $settings"

    # Count plugins
    local plugins=$(grep -c "^Plug " "$VIMRC_FILE" || true)
    echo "  Plugins defined: $plugins"

    # Count leader mappings
    local leader_maps=$(grep -c "<leader>" "$VIMRC_FILE" || true)
    echo "  Leader key mappings: $leader_maps"
}

# Clean generated files
clean() {
    log_info "Cleaning generated files..."

    if [[ -f "$VIMRC_FILE" ]]; then
        rm -f "$VIMRC_FILE"
        log_success "Removed .vimrc"
    else
        log_info "No .vimrc file to clean"
    fi
}

# Watch for changes and auto-regenerate
watch_and_regenerate() {
    log_info "Watching for changes in Neovim configuration..."
    log_info "Press Ctrl+C to stop watching"

    if ! command -v inotifywait >/dev/null 2>&1; then
        log_error "inotifywait is not installed"
        log_info "Install inotify-tools package to use watch functionality"
        exit 1
    fi

    local watch_dirs=(
        "$SCRIPT_DIR/lua/gamma/settings"
        "$SCRIPT_DIR/lua/gamma/remap"
    )

    # Initial generation
    generate_vimrc

    while true; do
        # Watch for changes in configuration directories
        inotifywait -r -e modify,create,delete "${watch_dirs[@]}" 2>/dev/null
        log_info "Configuration change detected, regenerating .vimrc..."
        generate_vimrc
        sleep 1
    done
}

# Show help
show_help() {
    cat <<EOF
Usage: $0 [command]

Commands:
  generate    - Generate .vimrc from Neovim configuration (default)
  test        - Test the generated .vimrc for syntax errors
  install     - Install .vimrc to home directory (~/.vimrc)
  compare     - Compare generated .vimrc with existing ~/.vimrc
  stats       - Show statistics about the generated .vimrc
  clean       - Remove generated .vimrc file
  watch       - Watch for changes and auto-regenerate .vimrc
  all         - Generate, test, and show stats
  help        - Show this help message

Examples:
  $0                # Generate .vimrc
  $0 generate       # Same as above
  $0 test           # Test generated .vimrc
  $0 install        # Generate and install .vimrc
  $0 all            # Full workflow: generate, test, stats
  $0 watch          # Watch and auto-regenerate on changes

Files:
  Input:  Neovim configuration in lua/gamma/
  Output: .vimrc (generated vim configuration)
  Generator: generate_vimrc.lua
EOF
}

# Main function
main() {
    local command="${1:-generate}"

    case "$command" in
    "generate" | "gen" | "g")
        generate_vimrc
        ;;
    "test" | "t")
        test_vimrc
        ;;
    "install" | "i")
        generate_vimrc
        test_vimrc
        install_vimrc
        ;;
    "compare" | "diff" | "c")
        compare_vimrc
        ;;
    "stats" | "statistics" | "s")
        stats_vimrc
        ;;
    "clean" | "cl")
        clean
        ;;
    "watch" | "w")
        watch_and_regenerate
        ;;
    "all" | "a")
        generate_vimrc
        test_vimrc
        stats_vimrc
        ;;
    "help" | "-h" | "--help" | "h")
        show_help
        ;;
    *)
        log_error "Unknown command: $command"
        echo ""
        show_help
        exit 1
        ;;
    esac
}

# Run main function with all arguments
main "$@"
