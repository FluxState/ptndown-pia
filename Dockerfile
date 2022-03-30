# syntax=docker/dockerfile:1.2
FROM golang:1.18-bullseye as Builder

ARG CACHEBUST="1"
RUN echo "$CACHEBUST"
ARG CI=""

RUN --mount=id=debian_apt,sharing=private,target=/var/cache/apt,type=cache \
    --mount=id=debian_apt_lists,sharing=private,target=/var/lib/apt/lists,type=cache \
    apt-get update && \
    [ ! -n "$CI" ] && apt-get dist-upgrade -y || : && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git

RUN git clone --depth 1 https://github.com/pia-foss/manual-connections.git /opt/pia

WORKDIR /opt/stoppropaganda
RUN git clone --branch 'updated-targets' --depth 1 https://github.com/FluxState/stoppropaganda.git . \
    && CGO_ENABLED=0 go build -ldflags="-s -w" -o stoppropaganda.exe ./cmd/stoppropaganda/main.go

RUN mkdir -p /opt/go \
    && GOPATH=/opt/go go install github.com/Arriven/db1000n@latest


FROM ubuntu:22.04
COPY --from=Builder /opt/pia/ /opt/pia/
COPY --from=Builder /opt/stoppropaganda/stoppropaganda.exe /opt/
COPY --from=Builder /opt/go/ /opt/go/

ARG CACHEBUST="1"
RUN echo "$CACHEBUST"
ARG CI=""

RUN --mount=id=ubuntu_apt,sharing=private,target=/var/cache/apt,type=cache \
    --mount=id=ubuntu_apt_lists,sharing=private,target=/var/lib/apt/lists,type=cache \
    apt-get update && \
    [ ! -n "$CI" ] && apt-get dist-upgrade -y || : && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cron curl dnsutils dumb-init git golang jq openvpn psmisc \
    && apt-get autoremove -y && rm -fr /var/log/* /tmp/*

ADD regions /config/regions
ADD resolv.conf /config/resolv.conf
ADD run.sh /run.sh
ADD start.sh /start.sh
COPY crontab /etc/crontab

ENV PIA_USER=**None** \
    PIA_PASS=**None** \
    DBN_PROMETHEUS=true \
    SP_USERAGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36'

CMD ["dumb-init", "/start.sh"]
