ARG ALPINE_VERSION="3.11"
FROM alpine:${ALPINE_VERSION} as s6-installer

# Install s6-overlay init system
RUN apk add --no-cache \
      curl \
      gpg \
      tar \
    && \
    rm -rf /var/cache/apk/* && \
    curl https://keybase.io/justcontainers/key.asc | gpg --import && \
    curl --output /tmp/s6-overlay.tar.gz https://github.com/just-containers/s6-overlay/releases/download/latest/s6-overlay-amd64.tar.gz && \
    curl --output /tmp/s6-overlay.tar.gz.sig https://github.com/just-containers/s6-overlay/releases/download/latest/s6-overlay-amd64.tar.gz.sig && \
    gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz && \
    mkdir /opt/s6 && \
    tar xvzf /tmp/s6-overlay.tar.gz -C /opt/s6

FROM alpine:${ALPINE_VERSION}

# Add some common requirements
RUN apk add --no-cache \
      bash \
      coreutils \
    && \
    rm -rf /var/cache/apk/*

# Add s6-overlay init system
COPY --from=s6-installer /opt/s6/ /

# Copy additional files to rootfs
COPY ./container/ /

ENTRYPOINT [ "/init" ]