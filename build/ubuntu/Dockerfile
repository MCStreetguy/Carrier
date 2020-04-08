ARG UBUNTU_VERSION="18.04"
FROM ubuntu:${UBUNTU_VERSION} as s6-installer

# Install s6-overlay init system
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      tar \
    && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/s6 && \
    curl https://keybase.io/justcontainers/key.asc | gpg --import && \
    curl --output /opt/s6/s6-overlay.tar.gz -L https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz && \
    curl --output /opt/s6/s6-overlay.tar.gz.sig -L https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz.sig && \
    gpg --verify /opt/s6/s6-overlay.tar.gz.sig /opt/s6/s6-overlay.tar.gz && \
    tar xvzf /opt/s6/s6-overlay.tar.gz -C /opt/s6 && \
    rm -rf /opt/s6/s6-overlay.tar.gz.sig /opt/s6/s6-overlay.tar.gz

FROM ubuntu:${UBUNTU_VERSION}

# Add some common requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      apt-utils \
      bash \
      ca-certificates \
      coreutils \
      dirmngr \
      findutils \
      iproute2 \
      netcat-openbsd \
    && \
    rm -rf /var/lib/apt/lists/*

# Set default shell for subsequent RUN instructions
SHELL [ "/bin/bash", "-c" ]

# Add s6-overlay init system
COPY --from=s6-installer /opt/s6/ /

# Copy additional files to rootfs
COPY ./container/ /

# Copy OS specific files to rootfs
COPY ./build/ubuntu/contents/ /

# Set up remaining skeleton
RUN s6-mkdir -pm 0755 /etc/carrier/conf.d

# Configuration
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=0
ENV S6_LOGGING=0
ENV S6_SYNC_DISKS=1

ENTRYPOINT [ "/init" ]