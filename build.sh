#!/bin/bash
set +x

docker build --platform linux/amd64 --progress=plain -t telosnetwork/testcontainer-nodeos-evm:latest .