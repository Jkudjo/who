# Changelog

All notable changes to SSH Security Monitor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2024-01-15

### Added
- **IPv6 support** for modern networks
- **Multiple firewall backends** (iptables, nftables, firewalld, pf)
- **Multi-service protection** (SSH, FTP, POP3, IMAP, SMTP)
- **Performance optimizations** with caching and batch processing
- **Enhanced IP validation** with IPv6 address support
- **Backend-specific security policies**
- **Advanced configuration options**
- **Syslog integration** for enterprise environments
- **PID file management** for daemon mode
- **Enhanced error handling** for different backends
- **JSON caching** for geographic information
- **Batch processing** for high-traffic environments
- **Memory optimization** for large log files

### Changed
- **Default threshold**: Changed from 3 to 2 failed attempts
- **Backend architecture**: Modular backend system
- **Performance**: Added caching and batch processing
- **Configuration**: Enhanced with backend and performance settings
- **Documentation**: Updated with new features and examples
- **Code structure**: Improved modularity and maintainability

### Fixed
- **IPv6 address handling** in banning functions
- **Backend compatibility** issues
- **Performance bottlenecks** in high-traffic environments
- **Memory usage** optimization
- **Error handling** for missing dependencies

## [2.0.0] - 2024-01-15

### Added
- **Major rewrite** from 57 lines to 518 lines of code
- **Configuration file support** (`/etc/ssh-monitor.conf`)
- **Command-line argument parsing** with 15+ options
- **Daemon mode** for continuous monitoring
- **JSON statistics output** for integration with monitoring systems
- **Whitelist/Blacklist management** for trusted and blocked IPs
- **Enhanced iptables integration** with dedicated SSH-MONITOR chain
- **Timeout protection** for geographic lookups
- **Signal handling** for clean shutdown
- **Dependency validation** with helpful error messages
- **Private IP detection** (local/private networks)
- **Enhanced pattern matching** for various SSH log formats
- **Root privilege validation** for iptables operations
- **Comprehensive logging** with structured reports
- **Systemd service integration** (`ssh-monitor.service`)
- **Automated installation script** (`install.sh`)
- **Test suite** with sample data (`test.sh`)
- **Makefile** for easy management
- **Comprehensive documentation** (README.md, CONTRIBUTING.md, SECURITY.md)
- **MIT license** for open source use

### Changed
- **Banning threshold**: Now bans after 2 failed attempts (configurable)
- **Date filtering**: Removed default date filtering to show all entries
- **Error handling**: Implemented strict bash settings (`set -euo pipefail`)
- **Logging**: Enhanced with colored output and structured logging
- **Security**: Improved with better validation and error handling

### Fixed
- **Permission issues** with temporary files
- **Variable scope issues** in functions
- **Error handling** for missing dependencies
- **Configuration validation** and loading

### Removed
- **Hardcoded values** in favor of configuration files
- **Basic error handling** in favor of comprehensive validation

## [1.0.0] - 2024-01-01

### Added
- **Basic SSH monitoring** functionality
- **IP extraction** from SSH logs
- **Geographic IP lookup** using geoiplookup
- **Automatic IP banning** with iptables
- **Basic logging** to `/var/log/ssh-banned.log`
- **Simple threshold-based banning** (3 failed attempts)

### Features
- Monitor successful SSH logins
- Monitor failed SSH login attempts
- Monitor disconnected sessions
- Ban IPs exceeding threshold
- Display geographic information for IPs
- Basic log file analysis

### Limitations
- Hardcoded configuration values
- Basic error handling
- No command-line options
- No daemon mode
- Limited documentation
- No installation automation

---

## Version History

### Version 2.1.0 (Current)
- **Enterprise features** with multiple backends
- **895 lines** of professional code
- **IPv6 support** for modern networks
- **Multi-service protection**
- **Performance optimizations**
- **Advanced caching system**

### Version 2.0.0
- **Major rewrite** with enterprise-grade features
- **518 lines** of professional code
- **15+ command-line options**
- **Configuration file support**
- **Systemd service integration**
- **Comprehensive documentation**

### Version 1.0.0 (Original)
- **Basic functionality** with 57 lines
- **Simple monitoring** and banning
- **No configuration options**
- **Limited features**

---

## Migration Guide

### From Version 2.0.0 to 2.1.0

1. **Backup existing configuration**:
   ```bash
   sudo cp /etc/ssh-monitor.conf /etc/ssh-monitor.conf.backup
   ```

2. **Update installation**:
   ```bash
   cd /path/to/who
   sudo ./install.sh
   ```

3. **Review new configuration options**:
   ```bash
   sudo nano /etc/ssh-monitor.conf
   ```

4. **Test new backends** (optional):
   ```bash
   # Test nftables backend
   sudo ./who --backend nftables -s
   
   # Test multi-service monitoring
   sudo ./who --services ssh,ftp -s
   ```

5. **Enable IPv6 support** (if needed):
   ```bash
   # IPv6 is enabled by default
   # To disable: sudo ./who --no-ipv6
   ```

### Breaking Changes

- **Backend selection**: New `BACKEND` configuration option
- **Service monitoring**: New `SERVICES` configuration option
- **Performance settings**: New caching and batch processing options
- **IPv6 support**: Enabled by default, can be disabled

---

## Future Plans

### Version 2.2.0 (Planned)
- **Web interface** for management
- **API endpoints** for integration
- **Database backend** for persistent storage
- **Advanced analytics** and reporting
- **Email notifications** for security events
- **Machine learning** for threat detection

### Version 2.3.0 (Planned)
- **Integration** with SIEM systems
- **Advanced filtering** options
- **Performance optimizations**
- **Docker support**
- **Kubernetes integration**

---

## Support

For support and questions:
- **Issues**: [GitHub Issues](https://github.com/Jkudjo/who/issues)
- **Documentation**: [README.md](README.md)
- **Security**: [SECURITY.md](SECURITY.md)

---

**Version**: 2.1.0  
**Last Updated**: January 2024  
**Author**: [Jkudjo](https://github.com/Jkudjo)  
**Repository**: [https://github.com/Jkudjo/who](https://github.com/Jkudjo/who) 