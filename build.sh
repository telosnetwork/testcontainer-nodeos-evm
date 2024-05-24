#!/bin/bash
set +x

docker build --platform linux/amd64 --progress=plain -t telos-node .
