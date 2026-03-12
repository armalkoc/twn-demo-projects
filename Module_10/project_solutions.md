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

NOTE: all the configuration files can be found in this repository - https://github.com/armalkoc/twn-demo-projects/tree/master/Module_10

In order to create and start mongodb Pod, I created db-secret.yaml file with the needed variables - https://github.com/armalkoc/twn-demo-projects/blob/master/Module_10/db-secret.yaml .

After that I created deployment and service configuration for the mongodb - https://github.com/armalkoc/twn-demo-projects/blob/master/Module_10/mongodb-deployment.yaml

At the end we can see our secret and mongodb Pod sucessfully created:
```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_10$ kubectl get secret | grep -i mdb
mdb-secret                               Opaque                           2      27m

armin@nb-pf565v12:~/twn-demo-projects/Module_10$ kubectl get deployment | grep -i mongodb && kubectl get pods | grep -i mongodb 
mongodb-deployment                          1/1     1            1           13m
mongodb-deployment-7cb7596479-2r7fl         1/1     Running      0           13m
```
Now it's needed to create mongo-express deployment and config as well since mongo-express needs mongo database server as a variable. Config file was created https://github.com/armalkoc/twn-demo-projects/blob/master/Module_10/db-config.yaml and also both, deployment and service for mongo-express were created https://github.com/armalkoc/twn-demo-projects/blob/master/Module_10/mongo-express-deployment.yaml.
After that we can see:
```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_10$ kubectl get deployment | grep -i mongo- && kubectl get pods | grep -i mongo- 
mongo-express-deployment                    1/1     1            1           12m
mongo-express-deployment-69b48dc5f4-ktnsc   1/1     Running      0           12m
```
At the end, since I have to access to the mongo-express UI through my we browser, it means I have to access to the mongo-express external service type LoadBalancer (nodePort 30001). To enable this its needed to do following:
```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_10$ minikube service mongo-express-service
┌───────────┬───────────────────────┬─────────────┬───────────────────────────┐
│ NAMESPACE │         NAME          │ TARGET PORT │            URL            │
├───────────┼───────────────────────┼─────────────┼───────────────────────────┤
│ default   │ mongo-express-service │ 8087        │ http://192.168.49.2:30001 │
└───────────┴───────────────────────┴─────────────┴───────────────────────────┘
```
Now I'm able to access to the mongo-express UI through my web browser:
<br />

![mongo-express-UI](mongo-express-UI.png)
<br />
</details>


