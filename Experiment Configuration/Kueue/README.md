# Running Kueue Experiments - Step-by-Step Guide

This guide outlines the steps to run and monitor Kueue experiments and retrieve the results. The experiments involve workload execution using Kueue in a Kubernetes cluster.


## Step 1: Managing Labels

To manage labels for nodes in the cluster, you can use the following commands:

To delete labels:

```
kubectl label nodes reana-summer-dhdkbhoe4pht-node-$i instance-type-
```

To add labels:

```
kubectl label nodes reana-summer-dhdkbhoe4pht-node-$i instance-type=benchmark
```

You can modify the labels.sh script and run it to apply the labels:

```
./labels.sh 
```

When changing resources, you can use the `python3 calculator.py` script if needed to adjust the ClusterQueue configuration.

## Step 2: Preparing Shared Storage

Before running experiments, you need to prepare the shared storage environment:


1. Enter the container:

```
k exec -it read-v6lg7 -c my-sidecar -- bash
```

2. Delete the existing extracted text file:

```
bash-5.2# cd data/benchmark/
bash-5.2# rm extracted.txt
```

3. Edit the configuration file `submit-second-job.yaml`

```
bash-5.2# vi submit-second-job.yaml 
```

4. Edit the executable bash file `submit-second-job.sh` to customize it for your specific experiment.

You will need to change: 
- name: experiment`number`-secondjob-NUMBER-a

Edit executable bash file:

```
bash-5.2# vi submit-second-job.sh 
```

You will need to change:
- echo "POD_NAME: experiment`number`-firstjob-NUMBER-a ; Time: $current_time ...
- echo "POD_NAME: experiment`number`-firstjob-NUMBER-a ; Time: $current_time ...

5. Create directories

```
bash-5.2# ./create-directories.sh 
```

6. Exit the container:

```
bash-5.2# exit
```

7. Delete all jobs:

```
k delete jobs --all
```

## Step 3: Monitoring the Cluster

Monitor the cluster queues using the following commands:

```
kubectl get clusterqueue reana-wf-cq -o wide -w

kubectl get clusterqueue reana-job-cq -o wide -w
```

Monitor the cluster using the various Python scripts, with one running on each terminal:

```
python3 jobsMonitor.py
```

```
./monitorK8s.sh 
```

## Step 4: Submitting the Workflow

Edit the submit-first-job.sh script as needed. You will need to change:

Modify the loop: `for i in {1..number}; do`

Create the workflow:

```
./create-first-job.sh 
```

Submit the workflow:

```
./submit-first-job.sh
```

## Step 5: Retrieving Results

1. Stop both workflows with `^C`.
2. Create a job to access the persistent volume:

```
k create -f Jobs-Kueue/read.yaml
```

3. Enter the container:

```
k exec -it read-4s947 -c my-sidecar -- bash
```

4. Enter the shared storage and edit the extract.sh script if needed:

```
bash-5.2# cd data/benchmark/
bash-5.2# vi extract.sh
```

5. Run the extraction script:

```
bash-5.2# ./extract.sh
```

6. Exit the container:
```
bash-5.2# exit
```

7. Copy the extracted data from the container to a local directory:

```
kubectl cp read-4s947:/data/benchmark/extracted.txt /tmp/poddata/test.txt
```

8. Add hours to even time differences from the job logs:

```
python3 addHours.py
```

9. Generate CSV:

```
python3 generatecsv.py
```

10. Generate plots:

```
reana-benchmark analyze -w kueue -n 1-384 -t 128wf-2nodes
```

## Step 6: Cleaning Up

After obtaining the results:

- Compress and save the zip file in the Experiments folder.
- Delete any plots, text files, and log files that are no longer needed.

By following these steps, you can conduct Kueue experiments, monitor the cluster, and retrieve and analyze the results efficiently.
