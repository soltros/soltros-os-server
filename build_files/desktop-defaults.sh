#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

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