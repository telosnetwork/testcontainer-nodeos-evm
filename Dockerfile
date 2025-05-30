FROM rust:1.86-slim-bullseye

RUN apt-get update && \
    apt-get install \
        -y \
        --no-install-recommends \
        jq \
        git \
        vim \
        wget \
        curl \
        zstd \
        net-tools \
        pkg-config \
        libssl-dev \
        libclang-dev \
        build-essential \
        ca-certificates

RUN wget https://github.com/AntelopeIO/leap/releases/download/v5.0.3/leap_5.0.3_amd64.deb && \
    dpkg -i leap_5.0.3_amd64.deb || apt-get install -f -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# 
# RUN . $HOME/.cargo/env && rustup default stable

# setup tcc
WORKDIR /

RUN git clone https://github.com/telosnetwork/telos-consensus-client.git tcc

WORKDIR /tcc

RUN bash build.sh

# setup reth
WORKDIR /

RUN git clone https://github.com/telosnetwork/telos-reth.git -b telos-main

WORKDIR /telos-reth

RUN bash build.sh

COPY tcc_config.toml /tcc/config.toml

COPY reth_env .env
COPY reth_jwt.hex data/jwt.hex

# setup nodeos
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

COPY chaos_monkey.sh /app/chaos_monkey.sh

# Do the extraction in entrypoint.sh so shared_memory.bin remains sparse
#RUN tar -xvf /node/data.tar.gz -C /node && mv /node/data /node/data-dir

#CMD ["nodeos", "--data-dir=/node/data-dir", "--config-dir=/node", "--disable-replay-opts", "--enable-stale-production"]

RUN mkdir /logs

CMD ["./entrypoint.sh"]
