#!/bin/bash
instance_type="benchmark"

for i in {4..50}; do
    node_name="reana-summer-dhdkbhoe4pht-node-$i"
    kubectl label nodes "$node_name" instance-type="$instance_type"
    echo "Labeled node $node_name with instance-type=$instance_type"
    # kubectl label nodes "$node_name" instance-type-
done
