#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Enable podman socket"
systemctl enable podman.socket

log "Enable thermal management services (if available)"
systemctl enable thermald.service 2>/dev/null || log "thermald not available"
systemctl enable mbpfan.service 2>/dev/null || log "mbpfan not available"

log "Enable PCP (Performance Co-Pilot) services"
# Core PCP daemon - must be started first
systemctl enable pmcd.service

# Performance Metrics Inference Engine services
systemctl enable pmie.service
systemctl enable pmie_farm.service

# Performance Metrics Archive Logger services  
systemctl enable pmlogger.service
systemctl enable pmlogger_farm.service

log "Enable Cockpit services"
systemctl enable cockpit.socket

log "Enable SSH server"
systemctl enable sshd.service

log "Enable Docker services"
systemctl enable docker.service
systemctl enable containerd.service

log "Enable Tailscale"
systemctl enable tailscaled.service

log "Enable audit daemon"
systemctl enable auditd.service

log "Enable libvirt virtualization services"
systemctl enable libvirtd.service
systemctl enable virtlogd.service
systemctl enable virtlockd.service

log "Configure systemd-remount-fs for rpm-ostree overlay filesystem"
# The error "overlay: No changes allowed in reconfigure" is NORMAL for rpm-ostree
# Exit code 32 means the filesystem can't be remounted, which is expected behavior
mkdir -p /etc/systemd/system/systemd-remount-fs.service.d
cat > /etc/systemd/system/systemd-remount-fs.service.d/rpm-ostree-overlay.conf << 'EOF'
[Service]
# Exit code 32 is normal for overlay filesystems - treat it as success
SuccessExitStatus=0 32
# Don't restart on "failure" since exit code 32 is expected
Restart=no
# Consider the service active even after exit
RemainAfterExit=yes
# Reduce log noise
StandardOutput=null
StandardError=journal
EOF

log "Configure rpm-ostreed for container builds"
mkdir -p /etc/rpm-ostreed.conf.d
cat > /etc/rpm-ostreed.conf.d/container-build.conf << 'EOF'
# Configuration for container builds
[Daemon]
# Prevent automatic updates during container build process
AutomaticUpdatePolicy=none
# Exit daemon quickly when idle to save resources
IdleExitTimeout=30
EOF

log "Service enablement completed"