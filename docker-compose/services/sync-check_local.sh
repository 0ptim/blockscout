#!/bin/sh

echo "Waiting for node to sync..."

# RPC endpoint for the defid service
RPC_ENDPOINT="http://172.18.224.1:8551"

# RPC user and password
RPC_USER="defid-user"
RPC_PASSWORD="mfemrkn564kjnfg34"

# Loop until the node is fully synced
while true; do
    # Define the JSON body of the JSON-RPC request
    JSON_DATA='{"jsonrpc": "2.0", "id":"1", "method": "getblockchaininfo", "params": []}'

    # Make the JSON-RPC request
    echo "Making JSON-RPC call to $RPC_ENDPOINT"
    RESPONSE=$(curl -s --user ${RPC_USER}:${RPC_PASSWORD} -X POST $RPC_ENDPOINT -H "Content-Type: application/json" --data "$JSON_DATA")

    # Print the response for debugging
    echo "Response: $RESPONSE"

    # Extract blocks and headers from the response
    BLOCKS=$(echo $RESPONSE | jq -r '.result.blocks')
    HEADERS=$(echo $RESPONSE | jq -r '.result.headers')

    echo "Blocks: $BLOCKS, Headers: $HEADERS"

    # Check for non-null and numeric blocks and headers before comparing
    if [ -n "$BLOCKS" ] && [ -n "$HEADERS" ] && [ "$BLOCKS" -eq "$HEADERS" ]; then
        echo "Node is synced with $BLOCKS blocks from $HEADERS headers"
        break
    elif [ -n "$BLOCKS" ] && [ -n "$HEADERS" ]; then
        echo "Node is syncing... $BLOCKS out of $HEADERS"
    else
        echo "Waiting for valid response..."
    fi

    sleep 10 # check every 10 seconds
done

# Continue with the rest of the script or command to start the backend service
