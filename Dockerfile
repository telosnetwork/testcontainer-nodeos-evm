FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y wget vim net-tools curl jq zstd

RUN wget https://github.com/AntelopeIO/leap/releases/download/v4.0.6/leap_4.0.6-ubuntu22.04_amd64.deb && \
    dpkg -i leap_4.0.6-ubuntu22.04_amd64.deb || apt-get install -f -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY config.ini /node/config.ini
COPY logging.json /node/logging.json
COPY data.tar.gz /node/data.tar.gz

RUN tar -xvf /node/data.tar.gz -C /node && mv /node/data /node/data-dir

CMD ["nodeos", "--data-dir=/node/data-dir", "--config-dir=/node", "--disable-replay-opts", "--enable-stale-production"]
