#!/usr/bin/bash

[[ -n "${SET_X:-}" ]] && set -x
set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing RPM packages"

# Layered Applications
LAYERED_PACKAGES=(
    # Core system
    fish
    lm_sensors
    starship

    # Server applications
    audit
    aide 
    selinux-policy
    nftables
    logwatch
    cockpit 
    cockpit-machines
    cockpit-storaged
    cockpit-networkmanager
    cockpit-selinux
    pcp
    libvirt
    virt-install
    qemu-kvm
    bridge-utils
    bind-utils
    ncdu
    openssh-server

    # Essential CLI tools
    btop
    ripgrep
    fd-find
    git-delta

    # System monitoring & hardware
    smartmontools
    usbutils
    pciutils

    # Development & container tools
    buildah
    skopeo

    # Network tools
    iperf3
    nmap
    wireguard-tools

    # File system support
    exfatprogs
    ntfs-3g
    btrfs-progs
)

dnf5 install --setopt=install_weak_deps=False --nogpgcheck -y "${LAYERED_PACKAGES[@]}"

log "Package install complete."

