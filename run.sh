#!/bin/bash
set +x

docker run --platform linux/amd64 \
    -it \
    --rm \
    -p 8888:8888 -p 9876:9876 -p 18999:18999 \
    --name telos-node \
    telosnetwork/testcontainer-nodeos-evm:latest
