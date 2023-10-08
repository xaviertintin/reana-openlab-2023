# Kueue Studies

This folder contains various studies and investigations into the functionality and behavior of the Kueue scheduler, a Kubernetes-native scheduling solution. Each subfolder corresponds to a specific study:

- [Borrowing](./borrowing/): An examination of Kueue's borrowing mechanism and its impact on resource allocation in Kubernetes clusters.

- [Cohort](./cohort/): An in-depth analysis of the Cohort feature in Kueue and its role in optimizing job scheduling and resource management.

- [Multiple LocalQueue](./multiple-localqueue/): A study exploring the use of multiple LocalQueue instances in Kueue for improved workload distribution and performance.

- [Namespace Selector](./namespace-selector/): An investigation into how Kueue handles namespace selection and its implications for workload isolation and management.

## Documentation

For detailed documentation on Kueue and its core concepts, refer to the official [Kueue Documentation](Documentation).

### Overview

The Kueue scheduler is a Kubernetes-native solution designed to optimize workload scheduling and resource management within Kubernetes clusters. It introduces several core concepts and APIs to represent cluster resources and workloads efficiently.

### Concepts

#### Core Kueue Concepts

This section of the documentation helps you learn about the components, APIs, and abstractions that Kueue uses to represent your cluster and workloads:

- **Resource Flavor**: An object that you can define to describe what resources are available in a cluster. Typically, a ResourceFlavor is associated with the characteristics of a group of Nodes.

- **Cluster Queue**: A cluster-scoped resource that governs a pool of resources, defining usage limits and fair sharing rules.

- **Local Queue**: A namespaced resource that groups closely related workloads belonging to a single tenant.

- **Workload**: An application that will run to completion. It is the unit of admission in Kueue and is sometimes referred to as a job.

#### Glossary

- **Admission**: The process of admitting a Workload to start (Pods to be created). A Workload is admitted by a ClusterQueue according to the available resources and gets resource flavors assigned for each requested resource. Sometimes referred to as workload scheduling or job scheduling (not to be confused with pod scheduling).

- **Cohort**: A group of ClusterQueues that can borrow unused quota from each other.

- **Queueing**: The time between a Workload is created until it is admitted by a ClusterQueue. Typically, the Workload will compete with other Workloads for available quota based on the fair sharing rules of the ClusterQueue.

## How to Use

You can explore each study by navigating to its respective subfolder. Each study may contain its own README and documentation, along with any scripts or tools used for analysis.

## Contribution

If you have insights, contributions, or suggestions related to any of these studies or Kueue in general, please feel free to get involved. Your input is valuable in advancing our understanding of Kueue and its capabilities.

## License

These studies are typically provided under open-source licenses specified within their respective subfolders. Be sure to check the individual study's license for details.

---

Last modified: March 23, 2023
© 2023 The Kubernetes Authors | Documentation Distributed under CC BY 4.0
