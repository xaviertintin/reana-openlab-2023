# Kueue Workflow Experiments

This folder contains the results of a series of experiments conducted to evaluate the performance and scalability of the Kueue scheduler in the context of workflow execution. The experiments focus on understanding the orchestration of workflow execution, testing the system under varying workloads and resource configurations, and analyzing the relationship between node counts and workflow execution time.

## Workflow Execution in Kueue

In the implementation of the Kueue scheduler, the workflow execution follows a well-defined sequence of interactions between Kueue and the Kubernetes Cluster. This orchestration begins when a user initiates a workflow run via kubectl. Kueue initiates the process by promptly creating the initial workflow submission job in a "suspended" state, while continuously monitoring resource availability within the Kubernetes Cluster. Once adequate resources become available, the Kubernetes Cluster takes control and generates the first workflow pod, which then records its starting timestamp.

## Testing

### Test Environment

Our evaluation unfolds within the usage of a Kubernetes cluster denominated as the "reana summer cluster," a robust testbed comprising of 50 worker nodes, and one master node, each armed with 15 GiB of memory and 8 CPU units. This setup provided the ideal computational capacity for a comprehensive comparison between the REANA and Kueue scheduling systems.

### Experiment Details

Within the Kueue testing phase, we embarked on a series of ten experiments, delving deep into its performance and scalability. Each experiment is meticulously designed to ensure a thorough evaluation and consists of two key types of jobs: Workflow Submission Jobs, intentionally configured with a memory limit of "150Mi", while the Workflow Task Jobs have a larger memory allocation set to "512Mi". This configuration reflects the emulation of computational tasks with workflow Task Jobs involving sleep jobs. Although simple, these sleep jobs serve as a representative workload when evaluating system performance and scalability.

### Node Expansion

To comprehensively assess Kueue's scalability, we have planned a significant expansion. We will double the number of nodes, scaling from 2 to 4, 8, 16, and 32 nodes, ensuring a wide range of node configurations.

### Workflow Scaling

In parallel with node expansion, the number of workflows for each experiment was tripled. This strategic scaling allowed us to explore the system's performance under varying workloads, taking into account a memory availability of 12 GiB per node. This choice not only ensured optimal performance but also facilitated an accurate evaluation of the system's capabilities in the context of node expansion studies.

### Performance Metrics

This evaluation will include measuring the total walltime from workflow initiation to completion. This approach allowed us to assess whether the progression follows a linear pattern, particularly regarding the correlation between the number of nodes and the speed of workflow execution.

### Memory Allocation Considerations

To carefully manage memory allocation and node capacity, the number of workflows and memory settings was adjusted to match the capabilities and constraints of our compute backend.

## Experiment Results

This evaluation provided a practical guideline for these experiments. While our initial tests focused on less CPU-intensive tasks, such as the "sleep" scenario, we anticipate the need to explore more computationally demanding scenarios in the future. The aim of these tests strikes a balance between realistic simulations and efficient cluster resource utilization, ensuring that the experiments yield meaningful insights into Kueue's performance. Our choice of running 384 workflows concurrently with available memory resources and 128 workflows for CPU-intensive scenarios provides a comprehensive evaluation of Kueue's capabilities under varying workloads and resource constraints.

In our analysis of speedup graphs for total execution time, the relationship between node counts and workflow execution time becomes evident. Specifically, with varying node counts (2, 4, 8, 16, 32) for both 128 and 384 workflows, we observe a significant improvement in workflow execution time as the number of nodes increases. In Figure~\ref{fig:longsleep}, we present a detailed breakdown of the execution timeline for the workflows. This graph highlights two distinct phases represented in orange and blue. The orange segment represents the time workflows spend in a pending state, offering room for improvement by fine-tuning Kueue's settings to optimize resource allocation and reduce the duration workflows stay in this pending state. On the other hand, the blue segment indicates the time workflows spend in the running state, executing tasks with a fixed 30-second sleep duration. This phase doesn't significantly benefit from parallelization, as the workload inherently involves a fixed task duration. Adding more resources or nodes doesn't lead to faster execution beyond a certain point, highlighting the inherent constraints of the workload.

## Conclusion

The experiments conducted in this study provide valuable insights into the performance and scalability of the Kueue scheduler. Understanding its behavior under different resource allocations and workloads is essential for optimizing workflow execution within a Kubernetes Cluster. The results and observations presented here contribute to enhancing the efficiency and reliability of scientific computing workflows using Kueue.

For detailed experiment-specific information, refer to the respective experiment subfolders.