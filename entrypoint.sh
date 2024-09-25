#!/bin/bash

set -x

tar -xvf data.tar.gz -C /node-rpc && mv /node-rpc/data /node-rpc/data-dir
tar -xvf data.tar.gz -C /node-eosio && mv /node-eosio/data /node-eosio/data-dir
tar -xvf data.tar.gz -C /node-prod-1 && mv /node-prod-1/data /node-prod-1/data-dir
tar -xvf data.tar.gz -C /node-prod-2 && mv /node-prod-2/data /node-prod-2/data-dir

nodeos --data-dir=/node-eosio/data-dir --config-dir=/node-eosio --enable-stale-production >> prod-eosio.log 2>&1 &
nodeos --data-dir=/node-prod-1/data-dir --config-dir=/node-prod-1 --enable-stale-production >> prod-1.log 2>&1 &
nodeos --data-dir=/node-prod-2/data-dir --config-dir=/node-prod-2 --enable-stale-production >> prod-2.log 2>&1 &

nodeos --data-dir=/node-rpc/data-dir --config-dir=/node-rpc --disable-replay-opts --enable-stale-production
