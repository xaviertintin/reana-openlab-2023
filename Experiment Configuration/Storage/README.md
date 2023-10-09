# Creating a Pod to Access Persistent Volume

This guide walks you through the process of creating a Kubernetes Pod named read-pod that allows you to connect to a persistent volume. You can use this Pod to access and read data stored in the persistent volume. Here's how to create the Pod:

```
kubectl create -f read.yaml
```

Enter the container:

```
kubectl exec -it read-4s947 -c my-sidecar -- bash
```

Enter the shared storage:

```
bash-5.2# cd data/benchmark/
bash-5.2# vi extract.sh
bash-5.2# ./extract.sh
```

Out of the container run: 

```
kubectl cp read-4s947:/data/benchmark/extracted.txt /tmp/poddata/test.txt
```
