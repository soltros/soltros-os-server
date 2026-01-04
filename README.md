# SoltrOS Server

A container-native server distribution based on [Universal Blue](https://universal-blue.org/) and Fedora Silverblue, designed for modern infrastructure with Docker CE, virtualization, and remote management capabilities.

## ✨ Features

### 🐳 Container Platform
- **Docker CE** with BuildX and Compose plugins
- **Podman & Buildah** for OCI container development
- **Tailscale** for secure mesh networking
- Container image signing with Sigstore/Cosign

### 🖥️ Server Management
- **Cockpit** web-based administration interface
- **Libvirt/KVM** virtualization platform
- **Performance Co-Pilot (PCP)** system monitoring
- **SSH server** pre-configured and ready

### 🔐 Security & Compliance
- **Signed container images** for supply chain security
- **Audit daemon** for system activity logging
- **AIDE** intrusion detection system
- **nftables** firewall configuration
- **SELinux** security policies

### 🛠️ Developer & Admin Tools
- Modern CLI utilities (btop, ripgrep, fd-find, git-delta)
- Network diagnostics (iperf3, nmap, bind-utils)
- System monitoring (smartmontools, lm_sensors)
- File system support (btrfs, exfat, ntfs-3g)

## 📦 Installation

SoltrOS Server is designed to be installed from the built ISO. However, you can also install iton top of an existing Fedora Silverblue/Kinoite installation using `bootc switch`. 

### Prerequisites
1. To install SoltrOS Server Edition, download the [ISO](https://publicweb.soltros.info/files/soltros-os-server-latest-42.iso), verify the [checksum](https://publicweb.soltros.info/files/soltros-os-server-latest-42.iso-CHECKSUM), and flash it to a USB.
2. Boot from USB, and complete the initial setup and boot into your Silverblue system

### Switch to SoltrOS Server
Switch to SoltrOS Server with:

```bash
# Switch to SoltrOS Server (requires reboot)
sudo bootc switch ghcr.io/soltros/soltros-os-server:latest

# Reboot to apply changes
sudo systemctl reboot
```

After reboot, you'll be running SoltrOS Server with all the container and server tools pre-installed.

### Verification
Verify your installation:

```bash
# Check OS information
cat /etc/os-release

# Verify container runtimes
docker --version
podman --version

# Check enabled services
systemctl status docker tailscaled cockpit.socket
```

## 🚀 Quick Start

### Container Operations
```bash
# Docker is ready to use
docker run hello-world

# Podman for rootless containers
podman run hello-world

# Build containers with Buildah
buildah --help
```

### Web Management
Access Cockpit web interface:
```bash
# Enable and access Cockpit (port 9090)
sudo systemctl enable --now cockpit.socket
# Navigate to https://your-server-ip:9090
```

### Secure Networking
```bash
# Connect to Tailscale network
sudo tailscale up

# Check Tailscale status
tailscale status
```

### Virtualization
```bash
# Check KVM capabilities
virt-host-validate

# Create VMs with virt-install
sudo virt-install --help
```

## 🔧 Customization

SoltrOS Server is built using rpm-ostree, making it immutable and atomic:

- **Layer packages**: Use `rpm-ostree install <package>`
- **Rollback changes**: Use `rpm-ostree rollback`
- **Update system**: Use `rpm-ostree upgrade`

For persistent customization, consider:
- Container-based applications
- Flatpak applications for desktop tools
- Configuration management with your preferred tools

## 🔒 Security

### Container Signing
All SoltrOS container images are signed with Sigstore for supply chain security. The signing policy is automatically configured during installation.

### System Security
- SELinux enforcing mode (can be configured)
- Audit logging enabled
- AIDE intrusion detection configured
- nftables firewall ready for configuration

## 📚 Documentation

- **Universal Blue**: [universal-blue.org](https://universal-blue.org/)
- **Fedora Silverblue**: [docs.fedoraproject.org/silverblue](https://docs.fedoraproject.org/en-US/fedora-silverblue/)
- **bootc**: [containers.github.io/bootc](https://containers.github.io/bootc/)
- **rpm-ostree**: [coreos.github.io/rpm-ostree](https://coreos.github.io/rpm-ostree/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development
```bash
# Clone the repository
git clone https://github.com/soltros/soltros-os-server.git
cd soltros-os-server

# Build locally with Podman/Docker
podman build -t soltros-server:local .
```

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Universal Blue** team for the excellent base platform
- **Fedora Project** for Silverblue and the container ecosystem
- **Red Hat** for rpm-ostree and container technologies
