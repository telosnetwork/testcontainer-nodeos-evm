FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y wget vim net-tools curl

RUN wget https://github.com/AntelopeIO/leap/releases/download/v5.0.2/leap_5.0.2_amd64.deb && \
    dpkg -i leap_5.0.2_amd64.deb || apt-get install -f -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY config.ini /node/config.ini
COPY genesis.json /node/genesis.json
COPY devnet.wallet /root/eosio-wallet/devnet.wallet

COPY setup_network.sh /app/setup_network.sh
COPY contracts /app/contracts

RUN bash /app/setup_network.sh


CMD ["nodeos", "--data-dir=/node/data-dir", "--config-dir=/node", "--enable-stale-production", "--genesis-json=/node/genesis.json"]
