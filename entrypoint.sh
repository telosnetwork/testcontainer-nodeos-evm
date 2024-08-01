#!/bin/bash

set -x

tar -xvf /node/data.tar.gz -C /node && mv /node/data /node/data-dir

nodeos --data-dir=/node/data-dir --config-dir=/node --disable-replay-opts --enable-stale-production