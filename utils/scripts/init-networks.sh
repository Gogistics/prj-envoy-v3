#!/bin/bash

trap "finish" INT TERM

finish() {
    local existcode=$?
    exit $existcode
}

ENVOY_NETWORK="atai_filter"
ENVOY_NETWORK_INSPECTION=$(docker network inspect $ENVOY_NETWORK)
ENVOY_NETWORK_INSPECTION=$?

if [ $ENVOY_NETWORK_INSPECTION -ne 0 ]
then
    echo "Creating $ENVOY_NETWORK network..."
    docker network create \
        --driver="bridge" \
        --subnet="175.10.0.0/24" \
        --gateway="175.10.0.1" \
        $ENVOY_NETWORK
else
    echo "Network, $ENVOY_NETWORK, has been created"
fi