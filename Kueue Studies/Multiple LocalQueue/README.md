# GKE Kueue Intro Tutorial Reference

This reference document provides an overview and step-by-step instructions for the [GKE Kueue Intro tutorial](https://cloud.google.com/kubernetes-engine/docs/tutorials/kueue-intro).

## Creating Namespaces

To begin, create two new namespaces called `team-a` and `team-b` using the following commands:

```bash
kubectl create ns team-a
kubectl create ns team-b
```

## Create the ResourceFlavor

A ResourceFlavor is an object that represents the variations in the nodes available in your cluster by associating them with node labels and taints. For example, you can use ResourceFlavors to represent VMs with different provisioning guarantees (for example, spot versus on-demand), architectures (for example, x86 versus ARM CPUs), brands and models (for example, Nvidia A100 versus T4 GPUs).

In this tutorial, the `kueue-autopilot` cluster has homogeneous resources. As a result, create a single ResourceFlavor for CPU, memory, ephemeral-storage, and GPUs, with no labels or taints.

[yaml file](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/blob/main/batch/kueue-intro/flavors.yaml)

## Create the ClusterQueue

A ClusterQueue is a cluster-scoped object that manages a pool of resources such as CPU, memory, GPU. It manages the ResourceFlavors, and limits the usage and dictates the order in which workloads are admitted.

[yaml file](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/blob/main/batch/kueue-intro/cluster-queue.yaml)

The order of consumption is determined by `.spec.queueingStrategy`, where there are two configurations:

- BestEffortFIFO
    
    - The default queueing strategy configuration.
    - The workload admission follows the first in first out (FIFO) rule, but if there is not enough quota to admit the workload at the head of the queue, the next one in line is tried.
- StrictFIFO
    
    - Guarantees FIFO semantics.
    - Workload at the head of the queue can block queueing until the workload can be admitted.

## Create the LocalQueue

A LocalQueue is a namespaced object that accepts workloads from users in the namespace. LocalQueues from different namespaces can point to the same ClusterQueue where they can share the resources' quota. In this case, LocalQueue from namespace `team-a` and `team-b` points to the same ClusterQueue `cluster-queue` under `.spec.clusterQueue`.

[yaml file](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/blob/main/batch/kueue-intro/local-queue.yaml)

```bash
➜  Config Files git:(main) ✗ kubectl apply -f local-queue.yaml
localqueue.kueue.x-k8s.io/lq-team-a created
localqueue.kueue.x-k8s.io/lq-team-b created
```

Check the local queues

```
➜  Config Files git:(main) ✗ kubectl get queues -n team-a
NAME        CLUSTERQUEUE    PENDING WORKLOADS   ADMITTED WORKLOADS
lq-team-a   cluster-queue   0                   0
➜  Config Files git:(main) ✗ kubectl get queues -n team-b
NAME        CLUSTERQUEUE    PENDING WORKLOADS   ADMITTED WORKLOADS
lq-team-b   cluster-queue   0                   0
```

## Run the jobs 

```bash
./create_jobs.sh job-teama.yaml job-teamb.yaml 10
```

Check the status with:

```bash
kubectl get clusterqueue cluster-queue -o wide -w
```

It is important to understand that each job runs 3 times given the parallelism configuration. Meaning that if we have a job that uses `500m cpu` and the cluster queue is configured with a `nominal quota equal to 2`, then it will only run one job at a time, because there aren't enough resources available to run any more.   

To test this, all you need to do is change the following parameters on each job configuration file:

```
parallelism: 1 # This Job will have 1 replicas running at the same time
completions: 1 # This Job requires 1 completions
```

## Clean your workspace

```yaml
k delete localqueue lq-team-a -n team-a
k delete localqueue lq-team-b -n team-b
k delete ns team-a
k delete ns team-b
k delete -f cluster-queue
```