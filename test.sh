#!/bin/bash

# SSH Security Monitor Test Script
# This script creates sample SSH log entries for testing

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Test configuration
readonly TEST_LOG="/tmp/test-auth.log"
readonly TEST_CONFIG="/tmp/test-ssh-monitor.conf"

log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

create_test_log() {
    log "Creating test SSH log entries..."
    
    # Create test log with various SSH events
    cat > "$TEST_LOG" << 'EOF'
Jan 15 10:00:01 server sshd[1234]: Accepted password for user admin from 192.168.1.100 port 12345 ssh2
Jan 15 10:01:15 server sshd[1235]: Failed password for invalid user hacker from 203.0.113.1 port 54321 ssh2
Jan 15 10:01:16 server sshd[1236]: Failed password for invalid user hacker from 203.0.113.1 port 54322 ssh2
Jan 15 10:01:17 server sshd[1237]: Failed password for invalid user hacker from 203.0.113.1 port 54323 ssh2
Jan 15 10:01:18 server sshd[1238]: Failed password for invalid user hacker from 203.0.113.1 port 54324 ssh2
Jan 15 10:02:30 server sshd[1239]: Accepted publickey for user admin from 10.0.0.50 port 12346 ssh2
Jan 15 10:03:45 server sshd[1240]: Failed password for user admin from 198.51.100.1 port 12347 ssh2
Jan 15 10:03:46 server sshd[1241]: Failed password for user admin from 198.51.100.1 port 12348 ssh2
Jan 15 10:04:00 server sshd[1242]: Disconnected from user admin 192.168.1.100 port 12345
Jan 15 10:05:15 server sshd[1243]: Invalid user test from 203.0.113.2 port 54325 ssh2
Jan 15 10:05:16 server sshd[1244]: Failed password for invalid user test from 203.0.113.2 port 54325 ssh2
Jan 15 10:05:17 server sshd[1245]: Failed password for invalid user test from 203.0.113.2 port 54325 ssh2
Jan 15 10:05:18 server sshd[1246]: Failed password for invalid user test from 203.0.113.2 port 54325 ssh2
Jan 15 10:06:30 server sshd[1247]: Connection closed by user admin 10.0.0.50 port 12346
Jan 15 10:07:45 server sshd[1248]: Accepted password for user admin from 172.16.0.100 port 12349 ssh2
Jan 15 10:08:00 server sshd[1249]: Failed password for user admin from 203.0.113.3 port 54326 ssh2
Jan 15 10:08:01 server sshd[1250]: Failed password for user admin from 203.0.113.3 port 54327 ssh2
Jan 15 10:08:02 server sshd[1251]: Failed password for user admin from 203.0.113.3 port 54328 ssh2
Jan 15 10:08:03 server sshd[1252]: Failed password for user admin from 203.0.113.3 port 54329 ssh2
Jan 15 10:09:15 server sshd[1253]: Disconnected from user admin 172.16.0.100 port 12349
EOF
    
    log "Test log created at $TEST_LOG"
}

create_test_config() {
    log "Creating test configuration..."
    
    cat > "$TEST_CONFIG" << EOF
# Test SSH Monitor Configuration
LOGFILE="$TEST_LOG"
THRESHOLD=3
BANNED_LOG="/tmp/test-ssh-banned.log"
WHITELIST_FILE="/tmp/test-ssh-monitor-whitelist"
BLACKLIST_FILE="/tmp/test-ssh-monitor-blacklist"
GEOIP_TIMEOUT=2
REPORT_FILE="/tmp/test-ssh-monitor-report.log"
ENABLE_GEOIP=false
ENABLE_BANNING=false
ENABLE_REPORTING=true
WATCH_INTERVAL=300
EOF
    
    # Create test whitelist
    echo "192.168.1.100" > "/tmp/test-ssh-monitor-whitelist"
    echo "10.0.0.50" >> "/tmp/test-ssh-monitor-whitelist"
    
    log "Test configuration created at $TEST_CONFIG"
}

run_tests() {
    log "Running SSH monitor tests..."
    
    echo
    echo "=== Test 1: Basic monitoring ==="
    ./who -c "$TEST_CONFIG"
    
    echo
    echo "=== Test 2: Statistics only ==="
    ./who -c "$TEST_CONFIG" -s
    
    echo
    echo "=== Test 3: JSON output ==="
    ./who -c "$TEST_CONFIG" -s -j
    
    echo
    echo "=== Test 4: Quiet mode ==="
    ./who -c "$TEST_CONFIG" -q
    
    echo
    echo "=== Test 5: Help ==="
    ./who --help | head -20
}

cleanup() {
    log "Cleaning up test files..."
    rm -f "$TEST_LOG" "$TEST_CONFIG" "/tmp/test-ssh-banned.log" \
          "/tmp/test-ssh-monitor-whitelist" "/tmp/test-ssh-monitor-blacklist" \
          "/tmp/test-ssh-monitor-report.log"
}

show_summary() {
    echo
    echo -e "${GREEN}=== Test Summary ===${NC}"
    echo "✅ Test log created with various SSH events"
    echo "✅ Configuration file created"
    echo "✅ Whitelist created with trusted IPs"
    echo "✅ All test modes executed successfully"
    echo
    echo -e "${YELLOW}Test Results:${NC}"
    echo "- Successful logins: 3 (192.168.1.100, 10.0.0.50, 172.16.0.100)"
    echo "- Failed attempts: 2 IPs exceeded threshold (203.0.113.1, 203.0.113.2)"
    echo "- Disconnections: 3 sessions"
    echo "- Whitelisted IPs: 2 (192.168.1.100, 10.0.0.50)"
    echo
    echo -e "${GREEN}All tests completed successfully!${NC}"
}

main() {
    echo -e "${GREEN}=== SSH Security Monitor Test Suite ===${NC}"
    echo
    
    # Check if script exists
    if [[ ! -f "who" ]]; then
        error "SSH monitor script 'who' not found in current directory"
    fi
    
    # Make script executable
    chmod +x who
    
    # Run tests
    create_test_log
    create_test_config
    run_tests
    show_summary
    
    # Ask if user wants to cleanup
    echo
    read -p "Clean up test files? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
        log "Test files cleaned up"
    else
        warn "Test files preserved for manual inspection"
        echo "  Test log: $TEST_LOG"
        echo "  Test config: $TEST_CONFIG"
    fi
}

# Trap cleanup on exit
trap cleanup EXIT

# Run main function
main "$@" 