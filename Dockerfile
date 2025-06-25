# Set base image and tag
ARG BASE_IMAGE=quay.io/fedora/fedora-bootc
ARG TAG_VERSION=latest
FROM ${BASE_IMAGE}:${TAG_VERSION}

# Stage 1: context for scripts (not included in final image)
FROM ${BASE_IMAGE}:${TAG_VERSION} AS ctx
COPY build_files/ /ctx/
COPY soltros.pub /ctx/soltros.pub

# Change perms
RUN chmod +x \
    /ctx/build.sh \
    /ctx/signing.sh \
    /ctx/overrides.sh \
    /ctx/cleanup.sh \
    /ctx/desktop-packages.sh \
    /ctx/disable-services.sh \
   /ctx/desktop-defaults.sh

# Stage 2: final image
FROM ${BASE_IMAGE}:${TAG_VERSION} AS soltros

LABEL org.opencontainers.image.title="SoltrOS Server" \
    org.opencontainers.image.description="Server-ready Fedora CoreOS image with Docker CE support" \
    org.opencontainers.image.vendor="Derrik" \
    org.opencontainers.image.version="42"

# Copy repos
COPY repo_files/tailscale.repo /etc/yum.repos.d/tailscale.repo
COPY repo_files/docker-ce.repo /etc/yum.repos.d/docker-ce.repo

# Create necessary directories for shell configurations
RUN mkdir -p /etc/profile.d /etc/fish/conf.d

RUN dnf5 install --setopt=install_weak_deps=False --nogpgcheck --skip-unavailable -y NetworkManager tailscale docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin openssh-server

RUN curl -L -o /tmp/webmin-current.rpm https://github.com/webmin/webmin/releases/download/2.402/webmin-2.402-1.noarch.rpm && \
    dnf5 install -y /tmp/webmin-current.rpm && \
    rm /tmp/webmin-current.rpm

# Enable Tailscale
RUN ln -sf /usr/lib/systemd/system/tailscaled.service /etc/systemd/system/multi-user.target.wants/tailscaled.service

# Enable Docker
RUN ln -sf /usr/lib/systemd/system/docker.service /etc/systemd/system/multi-user.target.wants/docker.service

RUN ln -sf /usr/lib/systemd/system/podman.socket /etc/systemd/system/sockets.target.wants/podman.socket

# Core PCP daemon - must be started first
RUN ln -sf /usr/lib/systemd/system/pmcd.service /etc/systemd/system/multi-user.target.wants/pmcd.service
# Performance Metrics Inference Engine services

RUN ln -sf /usr/lib/systemd/system/pmie.service /etc/systemd/system/multi-user.target.wants/pmie.service
RUN ln -sf /usr/lib/systemd/system/pmie_farm.service /etc/systemd/system/multi-user.target.wants/pmie_farm.service

# Performance Metrics Archive Logger services
RUN ln -sf /usr/lib/systemd/system/pmlogger.service /etc/systemd/system/multi-user.target.wants/pmlogger.service
RUN ln -sf /usr/lib/systemd/system/pmlogger_farm.service /etc/systemd/system/multi-user.target.wants/pmlogger_farm.service

RUN ln -sf /usr/lib/systemd/system/cockpit.socket /etc/systemd/system/sockets.target.wants/cockpit.socket

RUN ln -sf /usr/lib/systemd/system/docker.service /etc/systemd/system/multi-user.target.wants/docker.service
RUN ln -sf /usr/lib/systemd/system/containerd.service /etc/systemd/system/multi-user.target.wants/containerd.service

RUN ln -sf /usr/lib/systemd/system/auditd.service /etc/systemd/system/multi-user.target.wants/auditd.service

RUN ln -sf /usr/lib/systemd/system/libvirtd.service /etc/systemd/system/multi-user.target.wants/libvirtd.service
RUN ln -sf /usr/lib/systemd/system/virtlogd.service /etc/systemd/system/multi-user.target.wants/virtlogd.service
RUN ln -sf /usr/lib/systemd/system/virtlockd.service /etc/systemd/system/multi-user.target.wants/virtlockd.service

# Get rid of Plymouth

RUN dnf5 remove plymouth* -y && \
    systemctl disable plymouth-start.service plymouth-read-write.service plymouth-quit.service plymouth-quit-wait.service plymouth-reboot.service plymouth-kexec.service plymouth-halt.service plymouth-poweroff.service 2>/dev/null || true && \
    rm -rf /usr/share/plymouth /usr/lib/plymouth /etc/plymouth && \
    rm -f /usr/lib/systemd/system/plymouth* /usr/lib/systemd/system/*/plymouth* && \
    rm -f /usr/bin/plymouth /usr/sbin/plymouthd && \
    sed -i 's/rhgb quiet//' /etc/default/grub 2>/dev/null || true && \
    sed -i 's/splash//' /etc/default/grub 2>/dev/null || true && \
    sed -i '/plymouth/d' /etc/dracut.conf.d/* 2>/dev/null || true && \
    echo 'omit_dracutmodules+=" plymouth "' > /etc/dracut.conf.d/99-disable-plymouth.conf && \
    grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true && \
    dracut -f 2>/dev/null || true && \
    dnf5 autoremove -y && \
    dnf5 clean all

# Set identity and system branding with better error handling
RUN for i in {1..3}; do \
    curl --retry 3 --retry-delay 5 -Lo /usr/lib/os-release https://raw.githubusercontent.com/soltros/soltros-os-server/refs/heads/main/resources/os-release && \
    break || sleep 10; \
    done && \
    for i in {1..3}; do \
    curl --retry 3 --retry-delay 5 -Lo /etc/motd https://raw.githubusercontent.com/soltros/soltros-os-server/refs/heads/main/resources/motd && \
    break || sleep 10; \
    done && \
    for i in {1..3}; do \
    curl --retry 3 --retry-delay 5 -Lo /etc/dconf/db/local.d/00-soltros-settings https://raw.githubusercontent.com/soltros/soltros-os-server/refs/heads/main/resources/00-soltros-settings && \
    break || sleep 10; \
    done && \
    echo -e '\n\e[1;36mWelcome to SoltrOS Server — powered by Universal Blue\e[0m\n' > /etc/issue

# Mount and run build script from ctx stage
ARG BASE_IMAGE
RUN --mount=type=bind,from=ctx,source=/ctx,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    BASE_IMAGE=$BASE_IMAGE bash /ctx/build.sh
