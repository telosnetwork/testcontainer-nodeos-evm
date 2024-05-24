#!/bin/bash
set +x

docker run --platform linux/amd64 -d -p 8888:8888 -p 9876:9876 --name telos-node telos-node
