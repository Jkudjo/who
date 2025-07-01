#!/bin/bash

# SSH Security Monitor Installation Script
# Version: 2.0

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly SCRIPT_NAME="ssh-monitor"
readonly INSTALL_DIR="/usr/local/bin"
readonly CONFIG_DIR="/etc"
readonly SERVICE_DIR="/etc/systemd/system"
readonly LOG_DIR="/var/log"

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

check_dependencies() {
    local deps=("grep" "awk" "sort" "uniq" "iptables" "systemctl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}"
    fi
    
    # Check for optional geoip
    if ! command -v "geoiplookup" &> /dev/null; then
        warn "geoiplookup not found. Geographic information will be disabled."
        warn "Install with: apt-get install geoip-bin (Ubuntu/Debian) or yum install geoip (CentOS/RHEL)"
    fi
}

create_directories() {
    log "Creating directories..."
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
}

install_script() {
    log "Installing SSH monitor script..."
    
    if [[ ! -f "who" ]]; then
        error "Script file 'who' not found in current directory"
    fi
    
    cp "who" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    log "Script installed to $INSTALL_DIR/$SCRIPT_NAME"
}

create_config() {
    log "Creating configuration files..."
    
    # Main configuration
    cat > "$CONFIG_DIR/ssh-monitor.conf" << EOF
# SSH Monitor Configuration
LOGFILE="/var/log/auth.log"
THRESHOLD=3
BANNED_LOG="/var/log/ssh-banned.log"
WHITELIST_FILE="/etc/ssh-monitor-whitelist"
BLACKLIST_FILE="/etc/ssh-monitor-blacklist"
GEOIP_TIMEOUT=5
REPORT_FILE="/var/log/ssh-monitor-report.log"
ENABLE_GEOIP=true
ENABLE_BANNING=true
ENABLE_REPORTING=true
WATCH_INTERVAL=300
EOF
    
    # Create empty whitelist and blacklist files
    touch "$CONFIG_DIR/ssh-monitor-whitelist"
    touch "$CONFIG_DIR/ssh-monitor-blacklist"
    
    # Set proper permissions
    chmod 644 "$CONFIG_DIR/ssh-monitor.conf"
    chmod 644 "$CONFIG_DIR/ssh-monitor-whitelist"
    chmod 644 "$CONFIG_DIR/ssh-monitor-blacklist"
    
    log "Configuration created at $CONFIG_DIR/ssh-monitor.conf"
}

install_service() {
    log "Installing systemd service..."
    
    if [[ ! -f "ssh-monitor.service" ]]; then
        error "Service file 'ssh-monitor.service' not found in current directory"
    fi
    
    cp "ssh-monitor.service" "$SERVICE_DIR/"
    systemctl daemon-reload
    
    log "Service installed to $SERVICE_DIR/ssh-monitor.service"
}

setup_log_rotation() {
    log "Setting up log rotation..."
    
    cat > "/etc/logrotate.d/ssh-monitor" << EOF
/var/log/ssh-banned.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
    postrotate
        systemctl reload ssh-monitor > /dev/null 2>&1 || true
    endscript
}

/var/log/ssh-monitor-report.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF
    
    log "Log rotation configured at /etc/logrotate.d/ssh-monitor"
}

test_installation() {
    log "Testing installation..."
    
    # Test script execution
    if ! "$INSTALL_DIR/$SCRIPT_NAME" --help &> /dev/null; then
        error "Script test failed"
    fi
    
    # Test configuration loading
    if ! "$INSTALL_DIR/$SCRIPT_NAME" -s &> /dev/null; then
        error "Configuration test failed"
    fi
    
    log "Installation test passed"
}

show_post_install_info() {
    echo
    echo -e "${BLUE}=== SSH Security Monitor Installation Complete ===${NC}"
    echo
    echo -e "${GREEN}Installation Summary:${NC}"
    echo "  Script: $INSTALL_DIR/$SCRIPT_NAME"
    echo "  Config: $CONFIG_DIR/ssh-monitor.conf"
    echo "  Service: $SERVICE_DIR/ssh-monitor.service"
    echo "  Logs: $LOG_DIR/ssh-banned.log, $LOG_DIR/ssh-monitor-report.log"
    echo
    echo -e "${GREEN}Next Steps:${NC}"
    echo "1. Edit configuration: nano $CONFIG_DIR/ssh-monitor.conf"
    echo "2. Add trusted IPs: echo '192.168.1.100' >> $CONFIG_DIR/ssh-monitor-whitelist"
    echo "3. Start service: systemctl start ssh-monitor"
    echo "4. Enable auto-start: systemctl enable ssh-monitor"
    echo
    echo -e "${GREEN}Usage Examples:${NC}"
    echo "  Manual run: $SCRIPT_NAME"
    echo "  Daemon mode: $SCRIPT_NAME -d"
    echo "  Show stats: $SCRIPT_NAME -s"
    echo "  Unban IP: $SCRIPT_NAME -u 192.168.1.100"
    echo
    echo -e "${GREEN}Service Management:${NC}"
    echo "  Start: systemctl start ssh-monitor"
    echo "  Stop: systemctl stop ssh-monitor"
    echo "  Status: systemctl status ssh-monitor"
    echo "  Logs: journalctl -u ssh-monitor -f"
    echo
    echo -e "${YELLOW}Security Note:${NC}"
    echo "  - The service runs as root (required for iptables)"
    echo "  - Review and adjust whitelist before enabling"
    echo "  - Monitor logs regularly for false positives"
    echo
}

uninstall() {
    echo -e "${YELLOW}Uninstalling SSH Security Monitor...${NC}"
    
    # Stop and disable service
    systemctl stop ssh-monitor 2>/dev/null || true
    systemctl disable ssh-monitor 2>/dev/null || true
    
    # Remove files
    rm -f "$INSTALL_DIR/$SCRIPT_NAME"
    rm -f "$SERVICE_DIR/ssh-monitor.service"
    rm -f "$CONFIG_DIR/ssh-monitor.conf"
    rm -f "$CONFIG_DIR/ssh-monitor-whitelist"
    rm -f "$CONFIG_DIR/ssh-monitor-blacklist"
    rm -f "/etc/logrotate.d/ssh-monitor"
    
    # Reload systemd
    systemctl daemon-reload
    
    echo -e "${GREEN}Uninstallation complete${NC}"
    echo -e "${YELLOW}Note: Log files and iptables rules were not removed${NC}"
    echo "  To remove iptables rules: iptables -F SSH-MONITOR"
    echo "  To remove logs: rm -f $LOG_DIR/ssh-banned.log $LOG_DIR/ssh-monitor-report.log"
}

show_help() {
    cat << EOF
SSH Security Monitor Installation Script v2.0

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -u, --uninstall Uninstall SSH Security Monitor
    -t, --test      Test installation only

EXAMPLES:
    $0              # Install SSH Security Monitor
    $0 -u           # Uninstall SSH Security Monitor
    $0 -t           # Test installation without installing

EOF
}

main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--uninstall)
            check_root
            uninstall
            exit 0
            ;;
        -t|--test)
            check_root
            check_dependencies
            test_installation
            exit 0
            ;;
        "")
            # Normal installation
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
    
    echo -e "${BLUE}=== SSH Security Monitor Installation ===${NC}"
    echo
    
    check_root
    check_dependencies
    create_directories
    install_script
    create_config
    install_service
    setup_log_rotation
    test_installation
    show_post_install_info
}

# Run main function
main "$@" 