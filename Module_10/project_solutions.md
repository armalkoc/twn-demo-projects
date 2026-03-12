<details>
<summary>Deploy MongoDB and Mongo Express into local K8s cluster</summary>
<br />

**Setup local K8s cluster with Minikube**
In order to ensure that minikube uses a proper K8s cluster, we need to export KUBECONFIG environment variable and start minikube cluster.
```sh
armin@nb-pf565v12:~$ export KUBECONFIG=/home/armin/.kube/minikube.config
armin@nb-pf565v12:~$ echo $KUBECONFIG
/home/armin/.kube/minikube.config
armin@nb-pf565v12:~$ minikube start --driver=docker
😄  minikube v1.37.0 on Linuxmint 22
    ▪ KUBECONFIG=/home/armin/.kube/minikube.config
✨  Using the docker driver based on existing profile
🎉  minikube 1.38.1 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.38.1
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.48 ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.34.0 on Docker 28.4.0 ...
🔎  Verifying Kubernetes components...
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.2
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.2
    ▪ Using image registry.k8s.io/ingress-nginx/controller:v1.13.2
🔎  Verifying ingress addon...
🌟  Enabled addons: default-storageclass, storage-provisioner, ingress

❗  /usr/local/bin/kubectl is version 1.26.0, which may have incompatibilities with Kubernetes 1.34.0.
    ▪ Want kubectl v1.34.0? Try 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
<br />

**Deploy MongoDB and MongoExpress with configuration and credentials extracted into ConfigMap and Secret**

