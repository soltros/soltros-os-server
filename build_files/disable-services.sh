#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Cleaning up removed package remnants"

# Remove any leftover directories/files from removed packages
rm -rf /usr/share/plymouth* 2>/dev/null || true
rm -rf /var/lib/flatpak* 2>/dev/null || true
rm -rf /etc/flatpak* 2>/dev/null || true

# Services should already be gone with package removal, but clean up any systemd remnants
CLEANUP_SERVICES=(
    # Flatpak services (should be gone)
    flatpak-system-update.timer
    flatpak-system-update.service
    
    # Plymouth services (should be gone)
    plymouth-start.service
    plymouth-quit.service
    plymouth-quit-wait.service
    plymouth-read-write.service
    
    # Other desktop services not needed on server
    ModemManager.service
)

# Remove any leftover service files
for service in "${CLEANUP_SERVICES[@]}"; do
    if [ -f "/usr/lib/systemd/system/$service" ] || [ -f "/etc/systemd/system/$service" ]; then
        log "Removing leftover service file: $service"
        rm -f "/usr/lib/systemd/system/$service" "/etc/systemd/system/$service" 2>/dev/null || true
    fi
done

# Create PCP configuration directories to prevent service failures
log "Pre-creating PCP directories"
mkdir -p /var/log/pcp/pmlogger
mkdir -p /var/lib/pcp/config/pmlogger
mkdir -p /var/lib/pcp/tmp
mkdir -p /etc/pcp/pmlogger/control.d

# Ensure proper permissions for PCP
chown -R pcp:pcp /var/log/pcp /var/lib/pcp 2>/dev/null || true

# Reload systemd to clean up
systemctl daemon-reload 2>/dev/null || true

log "Service cleanup completed"