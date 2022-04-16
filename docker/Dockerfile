FROM alpine:3.14 as base

SHELL ["/bin/ash", "-x", "-c", "-o", "pipefail"]

# Based on https://github.com/djenriquez/nomad
LABEL maintainer="scp-support@astrazeneca.com"


RUN addgroup nomad \
 && adduser -S -G nomad nomad \
 && mkdir -p /nomad/data \
 && mkdir -p /etc/nomad \
 && chown -R nomad:nomad /nomad /etc/nomad

# Allow to fetch artifacts from TLS endpoint during the builds and by Nomad after.
# Install timezone data so we can run Nomad periodic jobs containing timezone information
RUN apk --update --no-cache add \
        ca-certificates \
        dumb-init \
        libcap \
        tzdata \
        su-exec \
  && update-ca-certificates

# https://github.com/sgerrand/alpine-pkg-glibc/releases
ARG GLIBC_VERSION=2.33-r0

ADD https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
ADD https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    glibc.apk
RUN apk add --no-cache \
        glibc.apk \
 && rm glibc.apk

# https://releases.hashicorp.com/nomad/
ARG NOMAD_VERSION=1.2.6

ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
    nomad_${NOMAD_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS \
    nomad_${NOMAD_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
    nomad_${NOMAD_VERSION}_SHA256SUMS.sig
RUN apk add --no-cache --virtual .nomad-deps gnupg \
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
  && gpg --keyserver pgp.mit.edu --keyserver keys.openpgp.org --keyserver keyserver.ubuntu.com --recv-keys "C874 011F 0AB4 0511 0D02 1055 3436 5D94 72D7 468F" \
  && gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS \
  && grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c \
  && unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && chmod +x /bin/nomad \
  && rm -rf "$GNUPGHOME" nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
  && apk del .nomad-deps

LABEL maintainer = "scp-support@astrazeneca.com"

FROM  base AS nomadpack
RUN apk update
RUN apk add \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    make \
    openssh-client \
    openssl \
    go \
    rsync
ARG NOMAD_PACK_BASEURL="https://releases.hashicorp.com"
ARG NOMAD_PACK_VERSION="0.0.1-techpreview2"
ARG NOMAD_PACK_ARCH="linux_amd64"

RUN set -ex \
  && apk --no-cache add ca-certificates curl unzip \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /srv/exports \
  && curl -fsSL --retry 5 "${NOMAD_PACK_BASEURL}/nomad-pack/${NOMAD_PACK_VERSION}/nomad-pack_${NOMAD_PACK_VERSION}_${NOMAD_PACK_ARCH}.zip" -o /tmp/archive.zip \
  && unzip /tmp/archive.zip -d /srv/exports

FROM base

ENV NOMAD_ADDR="http://127.0.0.1:4646"
ENV NOMAD_TOKEN=

# INSTALL PACKAGES
RUN set -ex \
  && apk --no-cache add ca-certificates git openssh-client dumb-init su-exec \
  && rm -f /var/cache/apk/*

# CREATE NON-PRIVILEGED USER
RUN set -ex \
  && addgroup pack \
  && adduser -g "Nomad-Pack User" -DG "pack" pack \
  && mkdir -p /home/pack/.ssh \
  && ssh-keyscan -H github.com >> /home/pack/.ssh/known_hosts \
  && ssh-keyscan -H bitbucket.org >> /home/pack/.ssh/known_hosts \
  && ssh-keyscan -H gitlab.com >> /home/pack/.ssh/known_hosts

FROM nomadpack AS trivy_scan
# hadolint ignore=DL3022
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
# ADD EXTERNAL RESOURCES
COPY --from=nomadpack ["/srv/exports/nomad-pack", "/usr/local/bin/"]
