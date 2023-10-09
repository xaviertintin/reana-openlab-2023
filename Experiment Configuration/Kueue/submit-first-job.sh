#!/bin/bash

for i in {1..8000}; do
    kubectl apply -f Jobs-Kueue/submit-first-job-$i.yaml
done