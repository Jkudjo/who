# SSH Security Monitor & IP Banning System v2.0

A comprehensive SSH security monitoring and automatic IP banning system with enhanced features for protecting SSH servers from brute force attacks and unauthorized access attempts.

## 🚀 Features

### Core Security Features
- **Real-time SSH monitoring** with detailed login attempt analysis
- **Automatic IP banning** when failed attempts exceed threshold
- **Geographic IP information** with country lookup
- **Whitelist/Blacklist management** for trusted and blocked IPs
- **Enhanced iptables integration** with dedicated SSH-MONITOR chain
- **Comprehensive logging** with structured report generation

### Advanced Capabilities
- **Daemon mode** for continuous monitoring
- **JSON statistics output** for integration with monitoring systems
- **Configuration file support** for persistent settings
- **Multiple log file formats** (auth.log, custom formats)
- **Timeout protection** for geographic lookups
- **Signal handling** for clean shutdown
- **Dependency validation** with helpful error messages

### Security Enhancements
- **Private IP detection** (local/private networks)
- **Enhanced pattern matching** for various SSH log formats
- **Root privilege validation** for iptables operations
- **Error handling** with graceful degradation
- **Strict bash settings** for security

## 📋 Requirements

### System Requirements
- Linux system with bash shell
- Root privileges (for iptables operations)
- SSH server with standard logging

### Dependencies
- **Required**: `grep`, `awk`, `sort`, `uniq`, `iptables`
- **Optional**: `geoiplookup` (for geographic information)

## 🛠️ Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/Jkudjo/who.git
cd who

# Run the automated installer
sudo ./install.sh
```

### Manual Installation

1. **Download the script**:
   ```bash
   wget https://raw.githubusercontent.com/Jkudjo/who/main/who
   ```

2. **Make executable**:
   ```bash
   chmod +x who
   ```

3. **Install to system path**:
   ```bash
   sudo cp who /usr/local/bin/ssh-monitor
   sudo ln -sf /usr/local/bin/ssh-monitor /usr/local/bin/who
   ```

4. **Install geoip tools** (optional):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install geoip-bin
   
   # CentOS/RHEL
   sudo yum install geoip
   ```

### Using Makefile

```bash
# Clone and install
git clone https://github.com/Jkudjo/who.git
cd who
make install

# Uninstall
make uninstall

# Run tests
make test
```

## 🚀 Usage

### Basic Usage

```bash
# Run with default settings
sudo ./who

# Run with custom threshold
sudo ./who -t 5

# Run in quiet mode
sudo ./who -q

# Show statistics only
sudo ./who -s
```

### Advanced Usage

```bash
# Run as daemon with 1-minute intervals
sudo ./who -d -i 60

# Use custom configuration file
sudo ./who -c /path/to/config.conf

# Disable automatic banning (monitor only)
sudo ./who --no-ban

# Output statistics in JSON format
sudo ./who -s -j

# Unban specific IP
sudo ./who -u 192.168.1.100
```

### Daemon Mode

```bash
# Start continuous monitoring
sudo ./who -d

# Custom interval (30 seconds)
sudo ./who -d -i 30

# Background execution
sudo nohup ./who -d -q > /dev/null 2>&1 &
```

## ⚙️ Configuration

### Configuration File

Create `/etc/ssh-monitor.conf` for persistent settings:

```bash
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
```

### Whitelist Management

Add trusted IPs to `/etc/ssh-monitor-whitelist`:

```bash
# Add trusted IPs (one per line)
echo "192.168.1.100" | sudo tee -a /etc/ssh-monitor-whitelist
echo "10.0.0.50" | sudo tee -a /etc/ssh-monitor-whitelist
```

### Blacklist Management

Manually add IPs to `/etc/ssh-monitor-blacklist`:

```bash
# Add blocked IPs (one per line)
echo "203.0.113.1" | sudo tee -a /etc/ssh-monitor-blacklist
```

## 📊 Output Examples

### Standard Output
```
=== 🚨 SSH Security Monitor v2.0 ===
Timestamp: 2024-01-15 14:30:25
Log file: /var/log/auth.log
Threshold: 3 failed attempts

✅ Successful SSH logins (today):
  IP: 192.168.1.100  🏠 Local/Private

❌ Failed SSH login attempts (today):
  IP: 203.0.113.45  🌍 United States
    Attempts: 5

🔌 Disconnected sessions (today):
  IP: 192.168.1.100  🏠 Local/Private

🚫 Currently banned IPs: 2
```

### JSON Statistics
```json
{
  "timestamp": "2024-01-15T14:30:25+00:00",
  "logfile": "/var/log/auth.log",
  "threshold": 3,
  "successful_logins": 1,
  "failed_attempts": 5,
  "disconnections": 1,
  "banned_ips": 2,
  "whitelisted_ips": 2,
  "blacklisted_ips": 1
}
```

## 🔧 Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-c, --config FILE` | Configuration file | `/etc/ssh-monitor.conf` |
| `-l, --logfile FILE` | SSH log file | `/var/log/auth.log` |
| `-t, --threshold NUM` | Failed attempts threshold | `3` |
| `-b, --ban-log FILE` | Banned IPs log file | `/var/log/ssh-banned.log` |
| `-w, --whitelist FILE` | Whitelist file | `/etc/ssh-monitor-whitelist` |
| `-k, --blacklist FILE` | Blacklist file | `/etc/ssh-monitor-blacklist` |
| `-r, --report FILE` | Report log file | `/var/log/ssh-monitor-report.log` |
| `-d, --daemon` | Run in daemon mode | `false` |
| `-i, --interval SEC` | Daemon interval in seconds | `300` |
| `-j, --json` | Output statistics in JSON format | `false` |
| `-q, --quiet` | Quiet mode (minimal output) | `false` |
| `--no-geoip` | Disable geographic IP lookup | `false` |
| `--no-ban` | Disable automatic IP banning | `false` |
| `--no-report` | Disable report logging | `false` |
| `-u, --unban IP` | Unban specific IP address | - |
| `-s, --stats` | Show statistics only | `false` |
| `-h, --help` | Show help message | - |

## 🔒 Security Considerations

### Best Practices
1. **Run as root**: Required for iptables operations
2. **Whitelist trusted IPs**: Prevent false positives
3. **Monitor logs regularly**: Review banned IPs and reports
4. **Use daemon mode**: For continuous protection
5. **Backup configuration**: Before making changes

### Firewall Integration
The script creates a dedicated `SSH-MONITOR` iptables chain:
```bash
# View current bans
sudo iptables -L SSH-MONITOR -n

# Flush all bans
sudo iptables -F SSH-MONITOR

# Remove the chain
sudo iptables -D INPUT -j SSH-MONITOR
sudo iptables -X SSH-MONITOR
```

### Log Rotation
Configure log rotation for the monitoring logs:

```bash
# /etc/logrotate.d/ssh-monitor
/var/log/ssh-banned.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
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
```

## 🐛 Troubleshooting

### Common Issues

**Permission Denied**
```bash
# Ensure running as root
sudo ./who
```

**Log File Not Found**
```bash
# Check log file location
ls -la /var/log/auth.log

# Use custom log file
./who -l /path/to/ssh.log
```

**GeoIP Not Working**
```bash
# Install geoip tools
sudo apt-get install geoip-bin

# Or disable geoip
./who --no-geoip
```

**Iptables Errors**
```bash
# Check iptables status
sudo iptables -L

# Reset SSH-MONITOR chain
sudo iptables -F SSH-MONITOR
```

### Debug Mode
Enable debug output:
```bash
DEBUG=true ./who
```

## 📈 Monitoring Integration

### Systemd Service
Create `/etc/systemd/system/ssh-monitor.service`:

```ini
[Unit]
Description=SSH Security Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssh-monitor -d -q
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable ssh-monitor
sudo systemctl start ssh-monitor
```

### Cron Job
Add to crontab for periodic monitoring:
```bash
# Check every 5 minutes
*/5 * * * * /usr/local/bin/ssh-monitor -q

# Daily report at 6 AM
0 6 * * * /usr/local/bin/ssh-monitor -s -j > /var/log/ssh-daily-stats.json
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit issues, feature requests, and pull requests.

## 🔒 Security

For security issues, please see our [Security Policy](SECURITY.md) and report vulnerabilities responsibly.

## ⚠️ Disclaimer

This tool is designed for educational and security purposes. Use responsibly and in accordance with your organization's security policies. The authors are not responsible for any misuse or damage caused by this software.

## 🔗 Related Projects

- [Fail2ban](https://github.com/fail2ban/fail2ban) - Intrusion prevention software
- [CrowdSec](https://github.com/crowdsecurity/crowdsec) - Modern security engine
- [SSHGuard](https://github.com/sshguard/sshguard) - SSH brute force protection

## 📈 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete history of changes and version information.

---

**Version**: 2.0.0  
**Last Updated**: January 2024  
**Author**: [Jkudjo](https://github.com/Jkudjo)  
**Repository**: [https://github.com/Jkudjo/who](https://github.com/Jkudjo/who) 