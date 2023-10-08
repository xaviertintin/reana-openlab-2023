# REANA 

[REANA](https://www.reana.io/) is a reproducible analysis platform allowing researchers to run containerised data analyses on remote compute clouds.

The analysis is structured based on four questions: (i) where is the input data and parameters, (ii) what code is used to analyse the data, (iii) which computing environments are used to run the analysis code, and (iv) what are the computational steps taken to arrive at the results.

# Running Kueue

## Get access to the cluster

To get access to the cluster you must have the `config` file in your folder directory where you would access this cluster. Here you run:

```
export KUBECONFIG=/Users/alextintin/Documents/OpenLab/K8s-Summer-Cluster/config
alias k='kubectl'
```
