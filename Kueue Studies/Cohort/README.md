## Cohort[](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/#cohort)

ClusterQueues can be grouped in _cohorts_. ClusterQueues that belong to the same cohort can borrow unused quota from each other.

To add a ClusterQueue to a cohort, specify the name of the cohort in the `.spec.cohort` field. All ClusterQueues that have a matching `spec.cohort` are part of the same cohort. If the `spec.cohort`field is empty, the ClusterQueue doesn’t belong to any cohort, and thus it cannot borrow quota from any other ClusterQueue.

### Flavors and borrowing semantics[](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/#flavors-and-borrowing-semantics)

When a ClusterQueue is part of a cohort, Kueue satisfies the following admission semantics:

- When assigning flavors, Kueue goes through the list of flavors in the relevant ResourceGroup inside ClusterQueue’s (`.spec.resourceGroups[*].flavors`). For each flavor, Kueue attempts to fit a Workload’s pod set according to the quota defined in the ClusterQueue for the flavor and the unused quota in the cohort. If the Workload doesn’t fit, Kueue evaluates the next flavor in the list.
- A Workload’s pod set resource fits in a flavor defined for a ClusterQueue resource if the sum of requests for the resource:
    1. Is less than or equal to the unused `nominalQuota` for the flavor in the ClusterQueue; or
    2. Is less than or equal to the sum of unused `nominalQuota` for the flavor in the ClusterQueues in the cohort, and
    3. Is less than or equal to the unused `nominalQuota + borrowingLimit` for the flavor in the ClusterQueue. In Kueue, when (2) and (3) are satisfied, but not (1), this is called _borrowing quota_.
- A ClusterQueue can only borrow quota for flavors that the ClusterQueue defines.
- For each pod set resource in a Workload, a ClusterQueue can only borrow quota for one flavor.

### Borrowing example[](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/#borrowing-example)

Assume you created the following two ClusterQueues:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "team-a-cq"
spec:
  namespaceSelector: {} # match all.
  cohort: "team-ab"
  resourceGroups:
    - coveredResources: ["cpu", "memory"]
      flavors:
        - name: "standard"
          resources:
            - name: "cpu"
              nominalQuota: 1
            - name: "memory"
              nominalQuota: 36Gi
        - name: "spot"
          resources:
            - name: "cpu"
              nominalQuota: 1
            - name: "memory"
              nominalQuota: 72Gi
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "team-b-cq"
spec:
  namespaceSelector: {} # match all.
  cohort: "team-ab"
  resourceGroups:
    - coveredResources: ["cpu", "memory"]
      flavors:
        - name: "standard"
          resources:
            - name: "cpu"
              nominalQuota: 1
            - name: "memory"
              nominalQuota: 36Gi
```

ClusterQueue `team-a-cq` can admit Workloads depending on the following scenarios:

- If ClusterQueue `team-b-cq` has no admitted Workloads, then ClusterQueue `team-a-cq` can admit Workloads with resources adding up to `12+9=21` CPUs and `48+36=84Gi` of memory.
- If ClusterQueue `team-b-cq` has pending Workloads and the ClusterQueue `team-a-cq` has all its `nominalQuota` quota used, Kueue will admit Workloads in ClusterQueue `team-b-cq` before admitting any new Workloads in `team-a-cq`. Therefore, Kueue ensures the `nominalQuota` quota for `team-b-cq` is met.


## Labels:

To add labels you can use:

```bash
kubectl label nodes reana-summer-dhdkbhoe4pht-node-<NUMBER> instance-type=<TYPE>
```

To remove labels you can use:

```bash
kubectl label nodes reana-summer-dhdkbhoe4pht-node-<NUMBER> instance-type-
```

For this particular test we have:

```
NodeLabel: instance-type

Label: standard
nodes:
- Node 0
- Node 1

Label: spot
nodes:
- Node 2
```

You can label the nodes with:

```bash
kubectl label nodes reana-summer-dhdkbhoe4pht-node-0 instance-type=standard
kubectl label nodes reana-summer-dhdkbhoe4pht-node-1 instance-type=standard
kubectl label nodes reana-summer-dhdkbhoe4pht-node-2 instance-type=spot
```

## Deployment

Create namespace:

```bash
k create ns team-a
k create ns team-b
```

Create cluster queue

```bash
k apply -f cluster-queue.yaml 
```

Create resource flavors

```bash
k apply -f flavors.yaml 
```

Create local queue

```bash
k apply -f local-queue.yaml
```

## Monitoring

Open two terminals to see how scheduling will be done:

For first ClusterQueue

```
kubectl get clusterqueue team-a-cq -o wide -w
```

For second ClusterQueue

```
kubectl get clusterqueue team-b-cq -o wide -w
```

You can also use K9s running this on the terminal:

```
k9s
```

## Inspection

Get the workloads:

```
k -n team-a get workloads
```

Describe any workflow:

```
 k -n team-a describe workload <NAME_WORKLOAD>
```

```bash
k get queues -n team-a 
k get queues -n team-b
```

## Testing


### Observations:

Given that each node was assigned `1 cpu`, and each Job demanded `0.5 cpu`, the following behavior worked as expected

**Cluster Quota A**

- Jobs: `sample-job-team-a` were submitted into the LocalQueue: `lq-team-a`
- LocalQueue: `lq-team-a` lives within the namespace: `team-a`
- LocalQueue: `lq-team-a` submit the workloads into the ClusterQueue: `team-a-cq`
- ClusterQueue: `team-a-cq` can run on nodes with the flavors: `[standard, spot]`. Given that two nodes on the cluster have the standard flavor and one node has the spot flavor, ClusterQueue A can submit jobs on all nodes.

**Cluster Quota B**

- Jobs: `sample-job-team-b` were submitted into the LocalQueue: `lq-team-b`
- LocalQueue: `lq-team-b` lives within the namespace: `team-b`
- LocalQueue: `lq-team-b` submit the workloads into the ClusterQueue: `team-b-cq`
- ClusterQueue: `team-b-cq` can run on nodes with the flavors: `[standard]`. Given that two nodes on the cluster have the standard flavor, ClusterQueue B can submit jobs on only one node.

It is expected that:

- Node 0 can have jobs from ClusterQueue A and B
- Node 1 can have jobs from ClusterQueue A and B
- Node 2 will only have to run jobs from ClusterQueue A.

Given that Cluster B that can only submit to 2 nodes, and ClusterQueue A can submit jobs on all nodes, we can observe a bottle neck in the `resource flavor standard`.

## Cleaning up

```
k delete workloads --all -n team-a 
k delete workloads --all -n team-b
```

