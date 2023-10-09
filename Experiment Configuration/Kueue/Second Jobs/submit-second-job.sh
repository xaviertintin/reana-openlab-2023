#!/bin/bash                                                                     
current_time=$(date +"%Y-%m-%d %H:%M:%S")
rm /data/benchmark/<NUMBER>/timestamp*.txt                                            

# Start the job                                                                 
kubectl create -f data/benchmark/<NUMBER>/submit-second-job-<NUMBER>.yaml      

#Files
echo "POD_NAME: submit-first-job-<NUMBER>-abcde ; Time: $current_time ; PHASE: Running" > /data/benchmark/<NUMBER>/timestamp1.txt
filename="/data/benchmark/<NUMBER>/timestamp2.txt"
while true; do
    if [ -s "$filename" ]; then
        echo "File is not empty."
        current_time=$(date +"%Y-%m-%d %H:%M:%S")
        echo "POD_NAME: submit-first-job-<NUMBER>-abcde ; Time: $current_time ; PHASE: Succeeded" > /data/benchmark/<NUMBER>/timestamp3.txt
        break
    else
        echo "File is empty."
    fi
    sleep 1
done
