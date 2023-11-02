#!/usr/bin/env bash

# Load Config File
[[ ! -f monitorwitness.env ]] && echo "Config File Does not Exist!" && exit 404
. ./monitorwitness.env

# Sanity Check
if [[ -z "$HEARTBEAT_URL" ]]; then
        echo "HEARTBEAT_URL Not Set!"
        exit 1
fi

# Return node head block
getheadblock() {
    local arg1="$1"
    headblock=$(curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_dynamic_global_properties", "params":[], "id":1}' $arg1 | jq -r '.result.head_block_number')
    echo "$headblock"
}

# Send Heartbeat
sendheartbeat() {
    echo "Sending Heartbeat"
    curl $HEARTBEAT_URL
}

# Zero failure counter
failures=0

# Get local last processed block
CURRENT_BLOCK=$(grep 'Got [0-9]\+ transactions on block [0-9]\+' $LOGFILE | tail -n 1 | grep -oP 'block \K\d+')
if [ -z "$CURRENT_BLOCK" ]; then
    echo "No Block"
    exit 1
fi

# Set Separator
IFS=','

# Iterate through nodes
for node in $NODES
do
    HEADBLOCK=$(getheadblock "$node")
    BLOCK_DIFFERENCE=$(expr $HEADBLOCK - $CURRENT_BLOCK)
    ABS_BLOCK_DIFFERENCE=${BLOCK_DIFFERENCE#-}
    echo $node $HEADBLOCK $CURRENT_BLOCK $ABS_BLOCK_DIFFERENCE

    if [ "$ABS_BLOCK_DIFFERENCE" -gt "$TOLERANCE" ]
    then
        ((failures++))
    fi
done

# Check failures against allowed failures
if [ "$failures" -le "$FAILURES_ALLOWED" ]
then
    sendheartbeat
fi