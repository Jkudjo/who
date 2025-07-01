#!/bin/bash

# SSH Security Monitor Release Script
# Version: 1.0

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly SCRIPT_NAME="who"
readonly VERSION_FILE="VERSION"
readonly CHANGELOG_FILE="CHANGELOG.md"

log() {
    echo -e "${GREEN}[RELEASE]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_git() {
    if ! command -v git &> /dev/null; then
        error "Git is required for releases"
    fi
    
    if [[ ! -d ".git" ]]; then
        error "Not in a git repository"
    fi
}

get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

update_version() {
    local new_version="$1"
    echo "$new_version" > "$VERSION_FILE"
    log "Updated version to $new_version"
}

update_changelog() {
    local version="$1"
    local date=$(date '+%Y-%m-%d')
    
    # Add new version entry to changelog
    sed -i "5i\\\n## [$version] - $date\\n\\n### Added\\n- New features and improvements\\n\\n### Changed\\n- Updates and modifications\\n\\n### Fixed\\n- Bug fixes and corrections\\n" "$CHANGELOG_FILE"
    
    log "Updated changelog for version $version"
}

create_release() {
    local version="$1"
    local tag_name="v$version"
    
    # Update version file
    update_version "$version"
    
    # Update changelog
    update_changelog "$version"
    
    # Commit changes
    git add .
    git commit -m "Release version $version"
    
    # Create tag
    git tag -a "$tag_name" -m "Release version $version"
    
    # Push changes
    git push origin main
    git push origin "$tag_name"
    
    log "Created release $tag_name"
}

show_help() {
    cat << EOF
SSH Security Monitor Release Script

Usage: $0 [OPTIONS] VERSION

OPTIONS:
    -h, --help      Show this help message
    -c, --check     Check current version
    -t, --test      Test release process (dry run)

EXAMPLES:
    $0 2.1.0        # Create release version 2.1.0
    $0 -c           # Check current version
    $0 -t 2.1.0     # Test release process

VERSION FORMAT:
    Use semantic versioning (e.g., 2.1.0, 1.0.1, 3.0.0)

EOF
}

check_version() {
    local current_version=$(get_current_version)
    echo "Current version: $current_version"
}

test_release() {
    local version="$1"
    log "Testing release process for version $version"
    
    # Check if version is valid
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Invalid version format. Use semantic versioning (e.g., 2.1.0)"
    fi
    
    # Check if tag already exists
    if git tag -l | grep -q "v$version"; then
        error "Tag v$version already exists"
    fi
    
    log "Release test passed for version $version"
}

main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--check)
            check_git
            check_version
            exit 0
            ;;
        -t|--test)
            if [[ -z "${2:-}" ]]; then
                error "Version required for test mode"
            fi
            check_git
            test_release "$2"
            exit 0
            ;;
        "")
            show_help
            exit 1
            ;;
        *)
            # Normal release
            local version="$1"
            check_git
            test_release "$version"
            create_release "$version"
            ;;
    esac
}

# Run main function
main "$@" 