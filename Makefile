# SSH Security Monitor Makefile
# Version: 2.0

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
CONFDIR = /etc
SERVICEDIR = /etc/systemd/system
LOGDIR = /var/log

SCRIPT_NAME = ssh-monitor
SCRIPT_FILE = who

.PHONY: all install uninstall clean test help

all: help

help:
	@echo "SSH Security Monitor - Available targets:"
	@echo "  install    - Install SSH Security Monitor"
	@echo "  uninstall  - Remove SSH Security Monitor"
	@echo "  test       - Run test suite"
	@echo "  clean      - Clean temporary files"
	@echo "  help       - Show this help message"

install:
	@echo "Installing SSH Security Monitor..."
	@sudo ./install.sh
	@echo "Installation complete!"

uninstall:
	@echo "Uninstalling SSH Security Monitor..."
	@sudo ./install.sh -u
	@echo "Uninstallation complete!"

test:
	@echo "Running test suite..."
	@./test.sh

clean:
	@echo "Cleaning temporary files..."
	@rm -f /tmp/ssh-monitor-stats-*.json
	@rm -f /tmp/test-auth.log /tmp/test-ssh-monitor.conf
	@rm -f /tmp/test-ssh-banned.log /tmp/test-ssh-monitor-*.log
	@echo "Cleanup complete!"

# Manual installation targets
install-script:
	@echo "Installing script to $(BINDIR)/$(SCRIPT_NAME)..."
	@sudo cp $(SCRIPT_FILE) $(BINDIR)/$(SCRIPT_NAME)
	@sudo chmod +x $(BINDIR)/$(SCRIPT_NAME)
	@sudo ln -sf $(BINDIR)/$(SCRIPT_NAME) $(BINDIR)/who

install-service:
	@echo "Installing systemd service..."
	@sudo cp ssh-monitor.service $(SERVICEDIR)/
	@sudo systemctl daemon-reload

install-config:
	@echo "Creating configuration files..."
	@sudo mkdir -p $(CONFDIR)
	@sudo touch $(CONFDIR)/ssh-monitor-whitelist
	@sudo touch $(CONFDIR)/ssh-monitor-blacklist
	@sudo chmod 644 $(CONFDIR)/ssh-monitor-whitelist
	@sudo chmod 644 $(CONFDIR)/ssh-monitor-blacklist

install-logs:
	@echo "Setting up log files..."
	@sudo mkdir -p $(LOGDIR)
	@sudo touch $(LOGDIR)/ssh-banned.log
	@sudo touch $(LOGDIR)/ssh-monitor-report.log
	@sudo chmod 644 $(LOGDIR)/ssh-banned.log
	@sudo chmod 644 $(LOGDIR)/ssh-monitor-report.log

# Development targets
dev-install: install-script install-config install-logs
	@echo "Development installation complete!"

dev-test:
	@echo "Running development tests..."
	@chmod +x $(SCRIPT_FILE)
	@./$(SCRIPT_FILE) --help > /dev/null && echo "Script test: PASS" || echo "Script test: FAIL" 