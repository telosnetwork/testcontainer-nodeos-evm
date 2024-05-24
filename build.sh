#!/bin/bash
set +x

docker build --platform linux/amd64 -t telos-node .
