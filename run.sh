#!/bin/bash
set +x

docker run --platform linux/amd64 \
    -it \
    --rm \
    --network=host \
    --name telos-node \
    testcontainer-nodeos-evm:latest

# -p 8888:8888 -p 9876:9876 -p 18999:18999 \
# -p 9545:9545 -p 9546:9546 -p 9551:9551 \
