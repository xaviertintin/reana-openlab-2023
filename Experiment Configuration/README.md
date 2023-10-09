# Get access to the cluster

To get access to the cluster you must have the `config` file in your folder directory where you would access this cluster. Here you run:

```
export KUBECONFIG=/Users/alextintin/Documents/OpenLab/K8s-Summer-Cluster/config
alias k='kubectl'
```

# Administer Cluster Quotas

Make sure the following conditions are met:

- A Kubernetes cluster is running.
- The kubectl command-line tool has communication with your cluster.
- [Kueue is installed](https://kueue.sigs.k8s.io/docs/installation).

## 1. Create a ClusterQueue

Create a single ClusterQueue to represent the resource quotas for your entire cluster.

```yaml
# cluster-queue.yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "cluster-queue"
spec:
  namespaceSelector: {} # match all.
  resourceGroups:
  - coveredResources: ["cpu", "memory"]
    flavors:
    - name: "default-flavor"
      resources:
      - name: "cpu"
        nominalQuota: 9
      - name: "memory"
        nominalQuota: 36Gi

```

To create the ClusterQueue, run the following command:

```shell
kubectl apply -f cluster-queue.yaml
```

This ClusterQueue governs the usage of [resource types](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-types) `cpu` and `memory`. Each resource type has a single [resource flavor](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue#resourceflavor-object), named `default` with a nominal quota.

The empty `namespaceSelector` allows any namespace to use these resources.

## 2. Create a ResourceFlavor

A resource flavor has node labels and/or taints to scope which nodes can provide it.

```yaml
# default-flavor.yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: "default-flavor"
```

To create the ResourceFlavor, run the following command:

```shell
kubectl apply -f default-flavor.yaml
```

## 3. Create LocalQueues

Users cannot directly send [workloads](https://kueue.sigs.k8s.io/docs/concepts/workload) to ClusterQueues. Instead, users need to send their workloads to a Queue in their namespace. Thus, for the queuing system to be complete, you need to create a Queue in each namespace that needs access to the ClusterQueue.

Write the manifest for the LocalQueue. It should look similar to the following:

```yaml
# default-user-queue.yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: LocalQueue
metadata:
  namespace: "default"
  name: "user-queue"
spec:
  clusterQueue: "cluster-queue"
```

To create the LocalQueue, run the following command:

```shell
kubectl apply -f default-user-queue.yaml
```



# Run A Job

## 0. Identify the queues available in your namespace
Run the following command to list the `LocalQueues` available in your namespace.

```shell
kubectl -n default get localqueues
# Or use the 'queues' alias.
kubectl -n default get queues
```

The output is similar to the following:

```bash
NAME         CLUSTERQUEUE    PENDING WORKLOADS   ADMITTED WORKLOADS
user-queue   cluster-queue   0                   0
```

The [ClusterQueue](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue) defines the quotas for the Queue.

## 1. Define the Job 

Running a Job in Kueue is similar to [running a Job in a Kubernetes cluster](https://kubernetes.io/docs/tasks/job/) without Kueue. However, you must consider the following differences:

- You should create the Job in a [suspended state](https://kubernetes.io/docs/concepts/workloads/controllers/job/#suspending-a-job), as Kueue will decide when it’s the best time to start the Job.
- You have to set the Queue you want to submit the Job to. Use the `kueue.x-k8s.io/queue-name`label.
- You should include the resource requests for each Job Pod.

Here is a sample Job with three Pods that just sleep for a few seconds.

```yaml
# sample-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: sample-job-
  labels:
    kueue.x-k8s.io/queue-name: user-queue
spec:
  parallelism: 3
  completions: 3
  suspend: true
  template:
    spec:
      containers:
      - name: dummy-job
        image: gcr.io/k8s-staging-perf-tests/sleep:latest
        args: ["30s"]
        resources:
          requests:
            cpu: 1
            memory: "200Mi"
      restartPolicy: Never

```

## 2. Run the Job

You can run the Job with the following command:

```shell
kubectl create -f sample-job.yaml
```

Internally, Kueue will create a corresponding [Workload](https://kueue.sigs.k8s.io/docs/concepts/workload) for this Job with a matching name.

```shell
kubectl -n default get workloads
```

The output will be similar to the following:

```shell
NAME                         QUEUE        ADMITTED BY     AGE
job-sample-job-hs88z-d9555   user-queue   cluster-queue   9s
```

## 3. Monitor the status of the workload

You can see the Workload status with the following command:

```shell
kubectl -n default describe workload job-sample-job-hs88z-d9555
```

If the ClusterQueue doesn’t have enough quota to run the Workload, the output will be similar to the following:

```output
Name:         sample-job-sl4bm
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  kueue.x-k8s.io/v1beta1
Kind:         Workload
Metadata:
  ...
Spec:
  ...
Status:
  Conditions:
    Last Probe Time:       2022-03-28T19:43:03Z
    Last Transition Time:  2022-03-28T19:43:03Z
    Message:               workload didn't fit
    Reason:                Pending
    Status:                False
    Type:                  Admitted
Events:               <none>

```

When the ClusterQueue has enough quota to run the Workload, it will admit the Workload. The output is similar to the following:

```output
Name:         job-sample-job-hs88z-d9555
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  kueue.x-k8s.io/v1beta1
Kind:         Workload
Metadata:
  Creation Timestamp:  2023-07-28T12:34:29Z
  Generation:          1
  Owner References:
    API Version:           batch/v1
    Block Owner Deletion:  true
    Controller:            true
    Kind:                  Job
    Name:                  sample-job-hs88z
    UID:                   75965f7c-ef34-40a5-b2ae-37bd153740c6
  Resource Version:        5446925
  UID:                     fce88d39-4208-4bba-bab1-eca76aab0626
Spec:
  Pod Sets:
    Count:  3
    Name:   main
    Template:
      Metadata:
      Spec:
        Containers:
          Args:
            30s
          Image:              gcr.io/k8s-staging-perf-tests/sleep:latest
          Image Pull Policy:  Always
          Name:               dummy-job
          Resources:
            Requests:
              Cpu:                     1
              Memory:                  200Mi
          Termination Message Path:    /dev/termination-log
          Termination Message Policy:  File
        Dns Policy:                    ClusterFirst
        Restart Policy:                Never
        Scheduler Name:                default-scheduler
        Security Context:
        Termination Grace Period Seconds:  30
  Priority:                                0
  Queue Name:                              user-queue
Status:
  Admission:
    Cluster Queue:  cluster-queue
    Pod Set Assignments:
      Count:  3
      Flavors:
        Cpu:     default-flavor
        Memory:  default-flavor
      Name:      main
      Resource Usage:
        Cpu:     3
        Memory:  600Mi
  Conditions:
    Last Transition Time:  2023-07-28T12:34:29Z
    Message:               Admitted by ClusterQueue cluster-queue
    Reason:                Admitted
    Status:                True
    Type:                  Admitted
    Last Transition Time:  2023-07-28T12:35:05Z
    Message:               Job finished successfully
    Reason:                JobFinished
    Status:                True
    Type:                  Finished
  Reclaimable Pods:
    Count:  2
    Name:   main
Events:
  Type    Reason    Age    From             Message
  ----    ------    ----   ----             -------
  Normal  Admitted  4m36s  kueue-admission  Admitted by ClusterQueue cluster-queue, wait time was 1s
```

To review more details about the Job status, run the following command:

```shell
kubectl -n default describe job sample-job-hs88z
```

The output is similar to the following:

```output
Name:             sample-job-hs88z
Namespace:        default
Selector:         controller-uid=75965f7c-ef34-40a5-b2ae-37bd153740c6
Labels:           kueue.x-k8s.io/queue-name=user-queue
Annotations:      batch.kubernetes.io/job-tracking: 
Parallelism:      3
Completions:      3
Completion Mode:  NonIndexed
Start Time:       Fri, 28 Jul 2023 14:34:29 +0200
Completed At:     Fri, 28 Jul 2023 14:35:05 +0200
Duration:         36s
Pods Statuses:    0 Active (0 Ready) / 3 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=75965f7c-ef34-40a5-b2ae-37bd153740c6
           job-name=sample-job-hs88z
  Containers:
   dummy-job:
    Image:      gcr.io/k8s-staging-perf-tests/sleep:latest
    Port:       <none>
    Host Port:  <none>
    Args:
      30s
    Requests:
      cpu:        1
      memory:     200Mi
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From                        Message
  ----    ------            ----   ----                        -------
  Normal  Suspended         7m48s  job-controller              Job suspended
  Normal  CreatedWorkload   7m48s  batch/job-kueue-controller  Created Workload: default/job-sample-job-hs88z-d9555
  Normal  Started           7m48s  batch/job-kueue-controller  Admitted by clusterQueue cluster-queue
  Normal  SuccessfulCreate  7m48s  job-controller              Created pod: sample-job-hs88z-cjw48
  Normal  SuccessfulCreate  7m48s  job-controller              Created pod: sample-job-hs88z-zctrs
  Normal  SuccessfulCreate  7m48s  job-controller              Created pod: sample-job-hs88z-qxk4g
  Normal  Resumed           7m48s  job-controller              Job resumed
  Normal  Completed         7m12s  job-controller              Job completed
```

Since events have a timestamp with a resolution of seconds, the events might be listed in a slightly different order from which they actually occurred.



## 4. View Persistent Volume logs

To view the logs that are submitted to the persistent volume create a pod with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: read-pod
spec:
  containers:
    - name: reader
    image: busybox:latest
    command: ["cat", "/data/output.txt"]
    volumeMounts:
      - name: data-volume
    mountPath: /data
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
  volumes:
    - name: data-volume
    persistentVolumeClaim:
      claimName: reana-summer-volume
  restartPolicy: Never
```

Submit the pod with:

```bash
kubectl apply -f read-pod.yaml
```

View the logs of the pod:

```yaml
kubectl logs read-pod 
```

# Testing
## Tests

```bash
kubectl create -f sample-job.yaml
```

Get workloadsk get

```bash
kubectl get workloads
```

You can see the Workload status with the following command:

```bash
k describe workload job-save-file-jobckjx5-cdd92
```

To review more details about the Job status, run the following command:

```bash
k describe job save-file-jobcmjdk
```

Submit the pod with:

```bash
kubectl apply -f read-pod.yaml
```

View the logs of the pod:

```yaml
kubectl logs read-pod 
```


## Run Tests:

```
kubectl create -f ./Jobs
```

Delete all

```bash
k apply -f delete-pod.yaml
k delete workloads --all
k delete jobs --all
k delete pods --all
```

