FROM golang:1.18-bullseye as Builder

ARG CACHEBUST="1"
RUN echo "$CACHEBUST"
ARG CI=""

RUN apt-get update && \
    [ ! -n "$CI" ] && apt-get dist-upgrade -y || : && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git

RUN git clone --depth 1 https://github.com/pia-foss/manual-connections.git /opt/pia

WORKDIR /opt/stoppropaganda
RUN git clone --branch 'cleaned4pia-vendor-update' --depth 1 https://github.com/FluxState/stoppropaganda.git . && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o stoppropaganda.exe ./cmd/stoppropaganda/main.go

RUN go install github.com/Arriven/db1000n@latest


FROM golang:1.18-bullseye
COPY --from=Builder /opt/pia/ /opt/pia/
COPY --from=Builder /go/ /go/
COPY --from=Builder /opt/stoppropaganda/stoppropaganda.exe /go/bin/

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
ARG SP_USERAGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"

ENV PIA_USER=$PIA_USER \
    PIA_PASS=$PIA_PASS \
    DBN_PROMETHEUS=$DBN_PROMETHEUS \
    SP_USERAGENT=$SP_USERAGENT

RUN chmod 0644 /etc/cron.d/ptndown-pia && \
    crontab /etc/cron.d/ptndown-pia && \
    touch /var/log/cron.log

CMD ["dumb-init", "/start.sh"]
