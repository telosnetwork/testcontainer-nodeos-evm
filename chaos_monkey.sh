#/!bin/bash

# This script is a chaos monkey that will randomly disconnect the RPC from the producer nodes
# and then reconnect them after a random amount of time. This is to produce forks for testing

# The script will run indefinitely until it is stopped

#P2P_NODES="127.0.0.1:9890 127.0.0.1:9891 127.0.0.1:9892"

# only disconnect 2 producers, leave one
P2P_NODES="127.0.0.1:9891 127.0.0.1:9892"
RPC_HTTP="127.0.0.1:8888"

SLEEP_BETWEEN_FORKS=1
FORK_DURATION_SMALL=1
FORK_DURATION_LARGE=8

call_net_api() {
  arg=$1
  for i in $P2P_NODES; do
    cleos -u http://$RPC_HTTP net $arg $i
  done
}

disconnect() {
    call_net_api "disconnect"
}

reconnect() {
    call_net_api "connect"
}

FORK_DURATION=$FORK_DURATION_SMALL
while sleep $SLEEP_BETWEEN_FORKS; do
    FORK_DURATION=1
    echo "Disconnecting RPC from producer nodes for $FORK_DURATION seconds"
    disconnect
    sleep $FORK_DURATION
    echo "Reconnecting RPC to producer nodes"
    reconnect
    if [ $FORK_DURATION -eq $FORK_DURATION_SMALL ]; then
      FORK_DURATION=$FORK_DURATION_LARGE
    else
      FORK_DURATION=$FORK_DURATION_SMALL
    fi
done