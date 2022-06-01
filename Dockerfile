FROM golang:1.18-bullseye as builder

ARG CACHEBUST="1"
RUN echo "$CACHEBUST"
ARG CI=""

RUN apt-get update && \
    [ ! -n "$CI" ] && apt-get dist-upgrade -y || : && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git

RUN git clone --depth 1 https://github.com/pia-foss/manual-connections.git /opt/pia

WORKDIR /build
RUN curl -O https://raw.githubusercontent.com/Arriven/db1000n/main/install.sh && \
    bash ./install.sh && \
    mkdir -p /go/bin && \
    mv /build/db1000n /go/bin/


FROM golang:1.18-bullseye as runner

ARG CACHEBUST="1"
RUN echo "$CACHEBUST"
ARG CI=""

RUN apt-get update && \
    [ ! -n "$CI" ] && apt-get dist-upgrade -y || : && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cron curl dnsutils dumb-init jq openvpn psmisc && \
    apt-get autoremove -y && apt-get clean && rm -fr /var/lib/apt/lists/* /var/log/* /tmp/*

COPY regions /config/regions
COPY resolv.conf /config/resolv.conf
COPY run.sh /run.sh
COPY start.sh /start.sh
COPY crontab /etc/cron.d/ptndown-pia

ARG PIA_USER="**None**"
ARG PIA_PASS="**None**"
ARG DBN_PROMETHEUS="true"

ENV PIA_USER=$PIA_USER \
    PIA_PASS=$PIA_PASS \
    DBN_PROMETHEUS=$DBN_PROMETHEUS

RUN chmod 0644 /etc/cron.d/ptndown-pia && \
    crontab /etc/cron.d/ptndown-pia && \
    touch /var/log/cron.log

COPY --from=builder /opt/pia/ /opt/pia/
COPY --from=builder /go/ /go/

CMD ["dumb-init", "/start.sh"]
