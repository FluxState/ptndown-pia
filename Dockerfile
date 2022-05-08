FROM golang:1.18-bullseye as Builder

ARG CACHEBUST="1"
RUN echo "$CACHEBUST"
ARG CI=""

RUN apt-get update && \
    [ ! -n "$CI" ] && apt-get dist-upgrade -y || : && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git

RUN git clone --depth 1 https://github.com/pia-foss/manual-connections.git /opt/pia

RUN go install github.com/Arriven/db1000n@latest


FROM golang:1.18-bullseye as Runner

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

COPY --from=Builder /opt/pia/ /opt/pia/
COPY --from=Builder /go/ /go/

CMD ["dumb-init", "/start.sh"]
