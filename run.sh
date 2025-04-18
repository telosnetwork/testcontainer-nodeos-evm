#!/bin/bash
set +x

docker run --platform linux/amd64 \
    -it \
    --rm \
    -p 8888:8888 \
    -p 9876:9876 \
    -p 18999:18999 \
    -p 8545:8545 \
    -p 9545:9545 \
    -p 8890:8890 \
    --name telos-node \
    testcontainer-nodeos-evm:latest
