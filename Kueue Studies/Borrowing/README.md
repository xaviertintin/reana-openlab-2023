# Borrowing in Kueue

This folder explores the concept of borrowing in Kueue, a Kubernetes-native scheduling solution. Borrowing plays a crucial role in optimizing resource allocation and job scheduling within Kubernetes clusters.

## ClusterQueues and Borrowing

Consider the following two ClusterQueues as an example:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "team-a-cq"
spec:
  namespaceSelector: # match namespace team-a
    matchExpressions:
      - key: team
        operator: In
        values:
          - team-a
  cohort: "team-ab"
  resourceGroups:
    - coveredResources: ["cpu", "memory"]
      flavors:
        - name: "standard"
          resources:
            - name: "cpu"
              nominalQuota: 1 # runs 2 jobs
            - name: "memory"
              nominalQuota: 36Gi
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "team-b-cq"
spec:
  namespaceSelector: # match namespace team-b
    matchExpressions:
      - key: team
        operator: In
        values:
          - team-b
  cohort: "team-ab"
  resourceGroups:
    - coveredResources: ["cpu", "memory"]
      flavors:
        - name: "standard"
          resources:
            - name: "cpu"
              nominalQuota: 2   # runs 2 jobs
            - name: "memory"
              nominalQuota: 72Gi
```

## Borrowing Scenarios
ClusterQueue team-a-cq can admit Workloads depending on the following scenarios:

- If ClusterQueue team-b-cq has no admitted Workloads, then ClusterQueue team-a-cq can admit Workloads with resources adding up to 1+2=3 CPUs and 48+36=84Gi of memory.
- If ClusterQueue team-b-cq has pending Workloads and ClusterQueue team-a-cq has all its nominalQuota quota used, Kueue will admit Workloads in ClusterQueue team-b-cq before admitting any new Workloads in team-a-cq. Therefore, Kueue ensures the nominalQuota quota for team-b-cq is met.

## Managing Borrowing Limits
To control the amount of resources a ClusterQueue can [borrow](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/#borrowinglimit) from others, you can set the .spec.resourcesGroup[*].flavors[*].resource[*].borrowingLimit [quantity](https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/) field. Here's an example:


```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "team-a-cq"
spec:
  namespaceSelector: # match namespace team-a
    matchExpressions:
      - key: team
        operator: In
        values:
          - team-a
  cohort: "team-ab"
  resourceGroups:
    - coveredResources: ["cpu", "memory"]
      flavors:
        - name: "standard"
          resources:
            - name: "cpu"
              nominalQuota: 1 # runs 2 jobs
              borrowingLimit: 0 # blocks this from borrowing resources from another ClusterQueue
            - name: "memory"
              nominalQuota: 36Gi
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: "team-b-cq"
spec:
  namespaceSelector: # match namespace team-b
    matchExpressions:
      - key: team
        operator: In
        values:
          - team-b
  cohort: "team-ab"
  resourceGroups:
    - coveredResources: ["cpu", "memory"]
      flavors:
        - name: "standard"
          resources:
            - name: "cpu"
              nominalQuota: 2   # runs 2 jobs
              borrowingLimit: 1 # lets me run up to 4 jobs (borrows 1 cpu from another ClusterQueue)
            - name: "memory"
              nominalQuota: 72Gi
```

In this case, setting borrowingLimit in ClusterQueue team-b-cq allows it to borrow CPU resources from team-a-cq, enabling more efficient resource utilization.

For more details on borrowing and other Kueue concepts, refer to the official [Kueue Documentation](https://kueue.sigs.k8s.io/docs/).