FROM debian:trixie-slim AS build

ARG TARGETARCH
ARG FISH_VERSION=4.9.3
ARG STARSHIP_VERSION=1.27.0

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates xz-utils

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) starship_arch=x86_64 ;; \
      arm64) starship_arch=aarch64 ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /out; \
    curl -fsSL "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-${starship_arch}-unknown-linux-musl.tar.gz" \
      | tar -xz -C /out

FROM scratch

COPY --from=build /out/starship /usr/local/bin/starship
