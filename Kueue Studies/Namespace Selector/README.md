# Namespace selector

The [Namespace Selector](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/#namespace-selector) in Kueue allows you to control which namespaces can have workloads admitted to the ClusterQueue. You can define this selector using a [label selector](https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/label-selector/#LabelSelector) within the `.spec.namespaceSelector` field.

To allow workloads from all namespaces, you can set the `.spec.namespaceSelector` field to an empty selector `{}`.

Here's an example of how to configure a `namespaceSelector`:

```yaml
namespaceSelector:
  matchExpressions:
  - key: team
    operator: In
    values:
    - team-a
```

# Managing Labels

## Add labels to the namespace

You can add labels to namespaces to match the criteria specified in the namespaceSelector. For instance, to apply the label 'team=team-a' to the 'team-a' namespace, you can use the following command:

```
kubectl label namespace team-a team=team-a
``` 

Similarly, to label the 'team-b' namespace as 'team=team-b', use this command:

```
kubectl label namespace team-b team=team-b
```

## Removing Labels from Namespaces

To remove labels from namespaces, you can execute commands like the following. This example removes the "team" label from the "team-a" namespace:

```bash
kubectl label namespace team-a team-
```

For the "team-b" namespace, you can remove the "team" label in a similar manner:

```bash
kubectl label namespace team-b team-
```

# ClusterQueue

To illustrate the use of Namespace Selector in a ClusterQueue, consider the following example:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
    name: "team-a-cq"
spec:
    namespaceSelector:
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
            nominalQuota: 2
            borrowingLimit: 1
        - name: "memory"
            nominalQuota: 36Gi
```

In this example, the ClusterQueue "team-a-cq" utilizes a Namespace Selector based on the "team" label. It specifies that workloads from namespaces with the label "team=team-a" will be admitted according to the ClusterQueue's rules. The ClusterQueue also defines resource allocations for CPU and memory, allowing for resource borrowing within certain limits.

This configuration showcases how Namespace Selectors can be employed to filter and limit the namespaces where a ClusterQueue's admission rules apply.