#!/bin/bash
set +x

docker stop telos-node
docker rm telos-node
./build.sh
./run.sh
