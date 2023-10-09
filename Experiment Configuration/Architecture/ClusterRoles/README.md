# Simulating Job Submissions with Nested Jobs

To enhance job submission simulations, we can create a job that dynamically creates another job within it. This approach allows us to test job orchestration and job creation processes effectively. To get started, follow these steps:

## Step 1: Configure the Outer Job

First, create an outer job configuration that will create and run the inner job. Here's an example YAML configuration for the outer job:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: my-job-
spec:
  template:
    spec:
      containers:
      - name: my-container
        image: bash
        command: ["bash", "-c"]
        args:
          - wget https://raw.githubusercontent.com/alextintin007/K8s-Summer-Cluster/main/Benchmark/Tests/my-second-job.yaml?token=GHSAT0AAAAAACCDD2BBPZ6VDKM6Q7GQYQ4UZG53HHA -O /data/my-second-job.yaml && cat /data/my-second-job.yaml
        volumeMounts:
            - name: data-volume
              mountPath: /data
      restartPolicy: Never
      volumes:
        - name: data-volume
          persistentVolumeClaim:
            claimName: reana-summer-volume
            readOnly: false
```

This configuration defines an outer job that downloads the declarative configuration for the inner job from a GitHub repository and saves it to the cluster's storage.

## Step 2: Create the Inner Job

Once the declarative file for the inner job is stored in the cluster's storage, you can create the inner job using the following configuration:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: my-job-
spec:
  template:
    spec:
      containers:
      - name: my-container
        image: bash
        command: ["bash", "-c"]
        args:
          - echo "Hello from first container"
        volumeMounts:
            - name: data-volume
              mountPath: /data
      - name: my-sidecar
        image: bitnami/kubectl
        command: ["bash", "-c"]
        args:
          - kubectl create -f /data/my-second-job.yaml 
        volumeMounts:
            - name: data-volume
              mountPath: /data
      restartPolicy: Never
      volumes:
        - name: data-volume
          persistentVolumeClaim:
            claimName: reana-summer-volume
            readOnly: false
```

This configuration defines the inner job, which consists of two containers: the first one echoes a message, and the second one uses kubectl to create the job specified in the /data/my-second-job.yaml file.

## Step 3: Handling Permissions

When you submit this job, you might encounter an error related to insufficient permissions to create a Job resource. To resolve this issue, you can grant the necessary permissions by adding ClusterRoles to the associated service account. Ensure that the service account has permissions to create jobs in the desired namespace.

By following these steps, you can simulate job submissions with nested jobs, allowing you to evaluate job orchestration and Kubernetes permissions effectively.