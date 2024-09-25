FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y wget vim net-tools curl jq zstd

RUN wget https://github.com/AntelopeIO/leap/releases/download/v5.0.2/leap_5.0.2_amd64.deb && \
    dpkg -i leap_5.0.2_amd64.deb || apt-get install -f -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY data.tar.gz data.tar.gz

COPY config-rpc.ini /node-rpc/config.ini
COPY logging.json /node-rpc/logging.json

COPY config-eosio.ini /node-eosio/config.ini
COPY logging.json /node-eosio/logging.json

COPY config-prod-1.ini /node-prod-1/config.ini
COPY logging.json /node-prod-1/logging.json

COPY config-prod-2.ini /node-prod-2/config.ini
COPY logging.json /node-prod-2/logging.json

COPY entrypoint.sh /app/entrypoint.sh

# Do the extraction in entrypoint.sh so shared_memory.bin remains sparse
#RUN tar -xvf /node/data.tar.gz -C /node && mv /node/data /node/data-dir

#CMD ["nodeos", "--data-dir=/node/data-dir", "--config-dir=/node", "--disable-replay-opts", "--enable-stale-production"]

CMD ["./entrypoint.sh"]
