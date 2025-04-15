#!/bin/bash

set -e

# setup and start nodeos
tar -xvf data.tar.gz -C /node-rpc && mv /node-rpc/data /node-rpc/data-dir
tar -xvf data.tar.gz -C /node-eosio && mv /node-eosio/data /node-eosio/data-dir
tar -xvf data.tar.gz -C /node-prod-1 && mv /node-prod-1/data /node-prod-1/data-dir
tar -xvf data.tar.gz -C /node-prod-2 && mv /node-prod-2/data /node-prod-2/data-dir

nodeos --data-dir=/node-eosio/data-dir --config-dir=/node-eosio --enable-stale-production >> prod-eosio.log 2>&1 &
nodeos --data-dir=/node-prod-1/data-dir --config-dir=/node-prod-1 --enable-stale-production >> prod-1.log 2>&1 &
nodeos --data-dir=/node-prod-2/data-dir --config-dir=/node-prod-2 --enable-stale-production >> prod-2.log 2>&1 &
/app/chaos_monkey.sh 2>&1 &

# start reth
RETH_ROOT=/telos-reth
RETH_BIN_PATH=$RETH_ROOT/target/release/telos-reth

if [ ! -f $RETH_BIN_PATH ] || [ ! -x $RETH_BIN_PATH ]; then
    echo "Error: telos-reth binary not found at $RETH_BIN_PATH\nHint: Did you run build.sh yet?"
    exit 1
fi

cd $RETH_ROOT

[ -f $RETH_ROOT/.env ] && . $RETH_ROOT/.env

[ -z "$LOG_LEVEL" ] && LOG_LEVEL=info
[ -z "$DATA_DIR" ] && DATA_DIR=$RETH_ROOT/data
[ -z "$CHAIN" ] && CHAIN=tevmmainnet
[ -z "$RETH_CONFIG" ] && RETH_CONFIG=$DATA_DIR/config.toml
[ -z "$RETH_RPC_ADDRESS" ] && RETH_RPC_ADDRESS=127.0.0.1
[ -z "$RETH_RPC_PORT" ] && RETH_RPC_PORT=8545
[ -z "$RETH_WS_ADDRESS" ] && RETH_WS_ADDRESS=127.0.0.1
[ -z "$RETH_WS_PORT" ] && RETH_WS_PORT=8546
[ -z "$RETH_AUTH_RPC_ADDRESS" ] && RETH_AUTH_RPC_ADDRESS=127.0.0.1
[ -z "$RETH_AUTH_RPC_PORT" ] && RETH_AUTH_RPC_PORT=8551
[ -z "$RETH_IPCPATH" ] && RETH_IPCPATH=$RETH_ROOT/reth.ipc
[ -z "$RETH_DISCOVERY_PORT" ] && RETH_DISCOVERY_PORT=30303
[ -z "$LOG_PATH" ] && LOG_PATH=$DATA_DIR/reth.log

$RETH_BIN_PATH node \
        --port $RETH_DISCOVERY_PORT \
        --log.stdout.filter $LOG_LEVEL \
        --datadir $DATA_DIR \
        --chain $CHAIN \
        --config $RETH_CONFIG \
        --http \
        --http.addr $RETH_RPC_ADDRESS \
        --http.port $RETH_RPC_PORT \
        --http.api all \
        --ws \
        --ws.api all \
        --ws.addr $RETH_WS_ADDRESS \
        --ws.port $RETH_WS_PORT \
        --authrpc.addr $RETH_AUTH_RPC_ADDRESS \
        --authrpc.port $RETH_AUTH_RPC_PORT \
        --ipcpath $RETH_IPCPATH \
        --discovery.port $RETH_DISCOVERY_PORT \
        --telos.telos_endpoint $TELOS_ENDPOINT \
        --telos.signer_account $TELOS_SIGNER_ACCOUNT \
        --telos.signer_permission $TELOS_SIGNER_PERMISSION \
        --telos.signer_key $TELOS_SIGNER_KEY \
    >> "$LOG_PATH" 2>&1 &

# start tcc
CONSENSUS_ROOT=/tcc
CONSENSUS_BIN_PATH=$CONSENSUS_ROOT/target/release/telos-consensus-client

if [ ! -f $CONSENSUS_BIN_PATH ] || [ ! -x $CONSENSUS_BIN_PATH ]; then
    echo "Error: telos-consensus-client binary not found at $CONSENSUS_BIN_PATH\nHint: Did you run build.sh yet?"
    exit 1
fi

[ -f $CONSENSUS_ROOT/.env ] && . $CONSENSUS_ROOT/.env

[ -z "$CONSENSUS_CONFIG" ] && CONSENSUS_CONFIG=$CONSENSUS_ROOT/config.toml
[ -z "$LOG_PATH" ] && LOG_PATH=$CONSENSUS_ROOT/consensus.log

$CONSENSUS_BIN_PATH --config $CONSENSUS_CONFIG >> "$LOG_PATH" 2>&1 &

cd /app

nodeos --data-dir=/node-rpc/data-dir --config-dir=/node-rpc --disable-replay-opts --enable-stale-production
