# syntax=docker/dockerfile:1.7

ARG ALPINE_VERSION=3.20
FROM --platform=$TARGETPLATFORM alpine:${ALPINE_VERSION}

ARG TARGETARCH
ARG TARGETVARIANT
ARG VOHIVE_VERSION=v1.5.5-10-gf9eb85d

LABEL org.opencontainers.image.title="VoHive" \
      org.opencontainers.image.description="VoHive Linux runtime image" \
      org.opencontainers.image.source="https://github.com/yinyuangu/vohive-release" \
      org.opencontainers.image.version="${VOHIVE_VERSION}"

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY vohive_${VOHIVE_VERSION}_linux_* /tmp/vohive/
COPY docker/entrypoint.sh /usr/local/bin/vohive-entrypoint

RUN set -eu; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      amd64) vohive_arch="amd64" ;; \
      arm64*) vohive_arch="arm64" ;; \
      armv7) vohive_arch="armv7" ;; \
      *) echo "unsupported target platform: ${TARGETARCH}${TARGETVARIANT}" >&2; exit 1 ;; \
    esac; \
    install -d /app/bin /app/config /app/data /app/logs; \
    install -m 0755 "/tmp/vohive/vohive_${VOHIVE_VERSION}_linux_${vohive_arch}" /app/bin/vohive; \
    chmod 0755 /usr/local/bin/vohive-entrypoint; \
    rm -rf /tmp/vohive

ENV CONFIG_PATH=/app/config/config.yaml \
    TZ=Asia/Shanghai

EXPOSE 7575

VOLUME ["/app/config", "/app/data", "/app/logs"]

ENTRYPOINT ["vohive-entrypoint"]

