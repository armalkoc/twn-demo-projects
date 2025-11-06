</details>

******

<details>
<summary>Project: Use Docker for local development</summary>
<br />

**Create docker network where our containers will be connected**
```sh
docker network create twn-demo-docker
```
**Start MongoDB container using the following command**
```sh
docker run -d --network twn-demo-docker \
-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
-e MONGO_INITDB_ROOT_PASSWORD=mongoadmin123 \
--name mongodb -p 27017:27017 \
mongo
```
**NOTE:** I have set up different credentials variables for mongodb container which caused that I had to change it in the server.js code later on !

**Start mongo-express UI for mongo database using the following command**
```sh
docker run -d --name mongo-express -p 8081:8081 -e ME_CONFIG_MONGODB_ADMINUSERNAME=mongoadmin \
-e ME_CONFIG_MONGODB_ADMINPASSWORD=mongoadmin123 \
-e ME_CONFIG_MONGODB_SERVER=mongodb \
--network twn-demo-docker \
mongo-express
```
**Start our NodeJS application**
First I started application locally on my localhost. There was the following issue:
```sh
MongoServerError: Authentication failed.
```
It's because username and password for mongodb container are already defined in the server.js app code and since I defined it differently for mongodb container, I had to fix it in the server.js file:
```js
// use when starting application locally with node command
//let mongoUrlLocal = "mongodb://admin:password@localhost:27017";
let mongoUrlLocal = "mongodb://mongoadmin:mongoadmin123@localhost:27017";

// use when starting application as docker container, part of docker-compose
//let mongoUrlDockerCompose = "mongodb://admin:password@mongodb";
let mongoUrlDockerCompose = "mongodb://mongoadmin:mongoadmin123@mongodb";
```
Now application starts without any problems:

```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_7/app$ npm install

added 154 packages, and audited 155 packages in 825ms

12 packages are looking for funding
  run `npm fund` for details

9 vulnerabilities (3 low, 1 moderate, 5 high)

To address all issues, run:
  npm audit fix

Run `npm audit` for details.
armin@nb-pf565v12:~/twn-demo-projects/Module_7/app$ node server.js 
app listening on port 3000!
```
When I start application locally it works:
```sh
node server.js
app listening on port 3000!
```
<br />

![nodejs-app](nodejs_app_locally.png)
<br />

But when I try to start nodejs application using in docker container it doesn't work
```sh
docker run -d -p 3000:3000 --name nodejs-app --network twn-demo-docker demo-docker-app:1.0
/opt/app/node_modules/mongodb/lib/sdam/topology.js:292
                const timeoutError = new error_1.MongoServerSelectionError(`Server selection timed out after ${serverSelectionTimeoutMS} ms`, this.description);
                                     ^

MongoServerSelectionError
    at Timeout._onTimeout (/opt/app/node_modules/mongodb/lib/sdam/topology.js:292:38)
    at listOnTimeout (node:internal/timers:581:17)
    at process.processTimers (node:internal/timers:519:7) {
  cause: MongoNetworkError
      at connectionFailureError (/opt/app/node_modules/mongodb/lib/cmap/connect.js:387:20)
      at Socket.<anonymous> (/opt/app/node_modules/mongodb/lib/cmap/connect.js:310:22)
      at Object.onceWrapper (node:events:639:26)
      at Socket.emit (node:events:524:28)
      at emitErrorNT (node:internal/streams/destroy:169:8)
      at emitErrorCloseNT (node:internal/streams/destroy:128:3)
      at process.processTicksAndRejections (node:internal/process/task_queues:82:21) {
    cause: AggregateError [ECONNREFUSED]: 
        at internalConnectMultiple (node:net:1122:18)
        at afterConnectMultiple (node:net:1689:7) {
      code: 'ECONNREFUSED',
      [errors]: [
        Error: connect ECONNREFUSED ::1:27017
            at createConnectionError (node:net:1652:14)
            at afterConnectMultiple (node:net:1682:16) {
          errno: -111,
          code: 'ECONNREFUSED',
          syscall: 'connect',
          address: '::1',
          port: 27017
        },
        Error: connect ECONNREFUSED 127.0.0.1:27017
            at createConnectionError (node:net:1652:14)
            at afterConnectMultiple (node:net:1682:16) {
          errno: -111,
          code: 'ECONNREFUSED',
```
I had to change connection string in the server.js, instead localhost i define mongodb in the connection string to be able to start nodejs application using "docker run" command:
```js
// use when starting application locally with node command
//let mongoUrlLocal = "mongodb://admin:password@localhost:27017";
let mongoUrlLocal = "mongodb://mongoadmin:mongoadmin123@mongodb:27017";
```
When I start nodejs app in the container it works now:
```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_7/app$ docker run -d -p 3000:3000 --name nodejs-app-newest3 --network twn-demo-docker demo-docker-app:2.3
40b09d6564d4a28f2fd746be8e48d24a45564eecdf0012a24807da03abf7bf23
armin@nb-pf565v12:~/twn-demo-projects/Module_7/app$ docker logs -f nodejs-app-newest3
app listening on port 3000!
```
</details>

******

<details>
<summary>Project: Docker Compose - Run multiple Docker containers</summary>
<br />

**Create docker-compose.yaml file**
<br />

Basically we will just use our commands from the prevous project and restructure it in the compose form:
```yaml
version: '3'
services:
  mongodb:
    image: mongo 
    container_name: mongodb 
    environment:
      - MONGO_INITDB_ROOT_USERNAME=mongoadmin
      - MONGO_INITDB_ROOT_PASSWORD=mongoadmin123
    ports:
      - 27017:27017
  mongo-express:
    image: mongo-express 
    container_name: mongo-express 
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=mongoadmin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=mongoadmin123
      - ME_CONFIG_MONGODB_SERVER=mongodb 
    ports:
      - 8081:8081
    restart: always
    depends_on:
      - mongodb 
```
**NOTE:**
<br />
We should change the connection string to the mongodb in the server.js to use mongoUrlDockerCompose instead mongoUrlLocal since containers will be able to communicate with each other using hostnames because the're started by compose and they belong to the same network created by compose.

```js
// Connect to the db using local application or docker compose variable in connection properties
  MongoClient.connect(mongoUrlDockerCompose, mongoClientOptions, function (err, client)
```
<br />

```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_7$ docker network ls | grep -i default
71ce0e75dafb   module_7_default   bridge    local
```

<br />

**Running MongoDB and Mongo-Express using docker-compose**
<br />

```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_7$ docker-compose -f docker-compose.yaml up 
WARN[0000] /home/armin/twn-demo-projects/Module_7/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 1/1
 ✔ Container mongodb Created
 Attaching to mongo-express, mongodb
mongo-express  | Waiting for mongo:27017...
mongo-express  | Mongo Express server listening at http://0.0.0.0:8081
mongo-express  | Server is open to allow connections from anyone (0.0.0.0)
mongo-express  | basicAuth credentials are "admin:pass", it is recommended you change this in your config.js!
```
After containers are started I can access to the mongo-express through WEB UI:
<br />

![mongo-express](mongo-express-ui.png)
<br />
</details>

******

<details>
<summary>Project: Dockerize Nodejs application and push to private Docker registry</summary>
<br />

**I wrote this Dockerfile:**
```yaml
FROM node:20-alpine

ENV MONGO_INITDB_ROOT_USERNAME=mongoadmin \
    MONGO_INITDB_ROOT_PASSWORD=mongoadmin123

RUN mkdir /opt/app

COPY ./app /opt/app 

WORKDIR /opt/app 

RUN npm install 

CMD ["node", "server.js"]
```
**Private Docker Registry on AWS (ECR)**
<br />

Private Docker Registry has been created and it's been called "docker-demo". Since my aws client was configured in one of previous lessons to use access_key from user arin instead user admin, I had to reconfigure it again to use access_key of admin user. After that I can build,tag and push Docker Image using the commands that are shown in the "View push commands" tan in the management console.
<br />

```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_7$ aws configure list
NAME       : VALUE                    : TYPE             : LOCATION
profile    : <not set>                : None             : None
access_key : ****************FLUK     : shared-credentials-file : 
secret_key : ****************TYDs     : shared-credentials-file : 
region     : eu-central-1             : config-file      : ~/.aws/config

armin@nb-pf565v12:~/twn-demo-projects/Module_7$ aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 647797471572.dkr.ecr.eu-central-1.amazonaws.com

WARNING! Your credentials are stored unencrypted in '/home/armin/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded

armin@nb-pf565v12:~/twn-demo-projects/Module_7$ docker build -t docker-demo .

armin@nb-pf565v12:~/twn-demo-projects/Module_7$ docker tag docker-demo:latest 647797471572.dkr.ecr.eu-central-1.amazonaws.com docker-demo:1.0

armin@nb-pf565v12:~/twn-demo-projects/Module_7$ docker images
REPOSITORY                                                    TAG                    IMAGE ID       CREATED          SIZE
647797471572.dkr.ecr.eu-central-1.amazonaws.com/docker-demo   1.0                    6ea6a5ef4395   39 minutes ago   160MB
demo-docker-app                                               3.0                    6ea6a5ef4395   39 minutes ago   160MB
docker-demo                                                   latest                 6ea6a5ef4395   39 minutes ago   160MB

armin@nb-pf565v12:~/twn-demo-projects/Module_7$ docker push 647797471572.dkr.ecr.eu-central-1.amazonaws.com/docker-demo:1.0
The push refers to repository [647797471572.dkr.ecr.eu-central-1.amazonaws.com/docker-demo]
50c4843482b6: Pushed 
5f70bf18a086: Pushed 
31c2befa5db7: Pushed 
aad6d01c8ba2: Pushed 
8bc61164599f: Pushed 
a81608eb20af: Pushed 
1548c3f692a1: Pushed 
256f393e029f: Pushed 
1.0: digest: sha256:4b19b1bac4b7a19735c701377f636e144f001da062dcde528f7451267bbdba8e size: 1992
```
We can see our Docker Image has been pushed to the ECR:
<br />

![ecr-docker-demo](ecr-docker-demo.png)
<br />

</details>

******

<details>
<summary>Project: Deploy Docker application on a server with Docker Compose</summary>
<br />

**Configure AWS CLI client on my EC2 instance to use admin access_key**
<br />

```sh
[ec2-user@ip-172-31-41-79 ~]$ aws configure list
Name                    Value             Type    Location
----                    -----             ----    --------
profile                <not set>             None    None
access_key     ****************FLUK shared-credentials-file    
secret_key     ****************TYDs shared-credentials-file    
region             eu-central-1      config-file    ~/.aws/config

[ec2-user@ip-172-31-41-79 ~]$ aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 647797471572.dkr.ecr.eu-central-1.amazonaws.com
WARNING! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```
<br />

**Copy docker-compose file from my local machine to the EC2 instance**
<br />

```sh
armin@nb-pf565v12:~/twn-demo-projects/Module_7$ scp -i /home/armin/.ssh/aws-web-docker-server.pem docker-compose.yaml \ 
ec2-user@54.93 231.146:/home/ec2-user/module7

docker-composeyaml                                                                                                                100%  731    48.3KB/s   00:00 
```
**Start the docker-compose.yaml on my EC2 instance**
<br />

```sh
ec2-user@ip-172-31-41-79 module7]$ docker-compose -f docker-compose.yaml up
WARN[0000] /home/ec2-user/module7/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 27/27
 ✔ mongodb Pulled                                                                                                                                                                       19.2s 
   ✔ 4b3ffd8ccb52 Pull complete                                                                                                                                                          5.5s 
   ✔ 34baad995762 Pull complete                                                                                                                                                          5.5s 
   ✔ 5d6f7cf8e15d Pull complete                                                                                                                                                          5.8s 
   ✔ f90aba9940a7 Pull complete                                                                                                                                                          5.9s 
   ✔ 5d3652024acd Pull complete                                                                                                                                                          6.0s 
   ✔ 74522aa03d00 Pull complete                                                                                                                                                          6.0s 
   ✔ ce8dccf1f4c1 Pull complete                                                                                                                                                         17.5s 
   ✔ a4ada45c862e Pull complete                                                                                                                                                         17.5s 
 ✔ mongo-express Pulled                                                                                                                                                                 14.9s 
   ✔ 619be1103602 Pull complete                                                                                                                                                          2.5s 
   ✔ 7e9a007eb24b Pull complete                                                                                                                                                          7.4s 
   ✔ 5189255e31c8 Pull complete                                                                                                                                                          7.5s 
   ✔ 88f4f8a6bc8d Pull complete                                                                                                                                                          7.5s 
   ✔ d8305ae32c95 Pull complete                                                                                                                                                          7.6s 
   ✔ 45b24ec126f9 Pull complete                                                                                                                                                          7.6s 
   ✔ 9f7f59574f7d Pull complete                                                                                                                                                         13.0s 
   ✔ 0bf3571b6cd7 Pull complete                                                                                                                                                         13.1s 
 ✔ nodejs-app Pulled                                                                                                                                                                     7.2s 
   ✔ 2d35ebdb57d9 Pull complete                                                                                                                                                          0.6s 
   ✔ 60e45a9660cf Pull complete                                                                                                                                                          3.4s 
   ✔ e74e4ed823e9 Pull complete                                                                                                                                                          3.8s 
   ✔ da04d522c98f Pull complete                                                                                                                                                          3.8s 
   ✔ 55281ac72444 Pull complete                                                                                                                                                          3.9s 
   ✔ 25084d3a37d3 Pull complete                                                                                                                                                          6.6s 
   ✔ 4f4fb700ef54 Pull complete                                                                                                                                                          6.6s 
   ✔ fae9ce8bbaf2 Pull complete                                                                                                                                                          6.9s 
[+] Running 4/4
 ✔ Network module7_default  Created                                                                                                                                                      0.2s 
 ✔ Container mongodb        Created                                                                                                                                                      0.2s 
 ✔ Container mongo-express  Created                                                                                                                                                      0.0s 
 ✔ Container nodejs-app     Created         


 [ec2-user@ip-172-31-41-79 ~]$ docker ps
CONTAINER ID   IMAGE                                                             COMMAND                  CREATED          STATUS          PORTS                                           NAMES
7416e7a7921e   mongo-express                                                     "/sbin/tini -- /dock…"   24 minutes ago   Up 24 minutes   0.0.0.0:8081->8081/tcp, :::8081->8081/tcp       mongo-express
5c68d3ada5a1   647797471572.dkr.ecr.eu-central-1.amazonaws.com/docker-demo:1.1   "docker-entrypoint.s…"   24 minutes ago   Up 24 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp       nodejs-app
7486afdebff5   mongo                                                             "docker-entrypoint.s…"   24 minutes ago   Up 24 minutes   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp   mongodb                                                                 
```
<br />

I also configured security group of the EC2 instance to open 8081 and 3000 ports for mongo-express and nodejs application:
<br />

![security-group](ec2-sg.png)
<br />

When I try to access to the mongo-express it works:
<br />

![mongo-express-ec2](mongo-express-ec2.png)
<br />

To be able to access on my nodejs application on port 3000, I had to adjust "index.html" file and use ec2-54-93-231-146.eu-central-1.compute.amazonaws.com instead localhost, since I was getting this issue:
```ssh
[ec2-user@ip-172-31-41-79 module7]$ docker exec -it nodejs-app grep ec2 /opt/app/index.html
  const response = await fetch('http://ec2-54-93-231-146.eu-central-1.compute.amazonaws.com:3000/get-profile');
  const response = await fetch('http://ec2-54-93-231-146.eu-central-1.compute.amazonaws.com:3000/update-profile',
```
<br />

![app-access-issue](app-access-issue.png)
<br />

I rebuild the Docker Image and start it with docker-compose and now it works perfectly:
<br />

![nodejs-app-works](nodejs-app-works.png)

</details>

******

<details>
<summary>Project: Persist data with Docker Volumes</summary>
<br />

We haven't configured volume for our mongodb docker container which menas if it would be stopped/restarted, we would lose all the data. To make our data persistent, we will configure named volume "mongodb-data" for the mongodb container in the docker-compose file:

```yaml
version: '3'
services:
  nodejs-app:
    image: 647797471572.dkr.ecr.eu-central-1.amazonaws.com/docker-demo:1.0
    container_name: nodejs-app 
    ports:
      - 3000:3000
    depends_on:
      - mongodb 
  mongodb:
    image: mongo 
    container_name: mongodb 
    environment:
      - MONGO_INITDB_ROOT_USERNAME=mongoadmin
      - MONGO_INITDB_ROOT_PASSWORD=mongoadmin123
    ports:
      - 27017:27017
    volumes:
      - mongodb-data:/data/db
  mongo-express:
    image: mongo-express 
    container_name: mongo-express 
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=mongoadmin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=mongoadmin123
      - ME_CONFIG_MONGODB_SERVER=mongodb 
    ports:
      - 8081:8081
    restart: always
    depends_on:
      - mongodb 
volumes:
  mongodb-data:
```
Since my volume hasn't been created after "docker-compose restart mongodb" command, I had to remove the containers and run docker-compose command again:

```sh
[ec2-user@ip-172-31-41-79 module7]$ docker volume ls | grep -i mongodb
local     module7_mongodb-data
[ec2-user@ip-172-31-41-79 module7]$ docker volume inspect module7_mongodb-data
[
    {
        "CreatedAt": "2025-11-06T09:38:35Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.config-hash": "c8c72212232ef31a5f860e0a5e0d09e3fb04761dbcdd36858368272dc99983f4",
            "com.docker.compose.project": "module7",
            "com.docker.compose.version": "2.40.2",
            "com.docker.compose.volume": "mongodb-data"
        },
        "Mountpoint": "/var/lib/docker/volumes/module7_mongodb-data/_data",
        "Name": "module7_mongodb-data",
        "Options": null,
        "Scope": "local"
    }
]
```
If I now edit some informations using WEB UI like this and save it:
![data-edit-ui](data-edit-ui.png)

I can see these changes in my mongodb using mongo-express UI:
<br />

![mongo-express-ui](mongo-express-ui_data.png)

</details>

******

<details>
<summary>Project: Create Docker repository on Nexus and push to it</summary>
<br />

**Create new Droplet VM**

I created new Deoplet VM "ubuntu-s-2vcpu-4gb-fra1-01":
- 4 GB Memory
- 80 GB Disk
- FRA1 - Ubuntu 24.04 (LTS) x64

I also creadet new firewall and configured inbound rules for SSH port 22 and Nexus port 8081 for my public IP:
<br />

![firewal-rulle](droplet-firewall-rule.png)
<br />
 
 Let's ensure our SSH connection works fine:
 ```sh
 armin@nb-pf565v12:~$ ssh -i /home/armin/.ssh/id_ed25519 root@139.59.143.140
The authenticity of host '139.59.143.140 (139.59.143.140)' can't be established.
ED25519 key fingerprint is SHA256:XYMtTaP97TYDvUsbFJD2W3hrHSU1dawPHONi7WQ0FaE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '139.59.143.140' (ED25519) to the list of known hosts.
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-71-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Nov  6 10:23:08 UTC 2025

  System load:  0.05              Processes:             114
  Usage of /:   2.5% of 76.45GB   Users logged in:       0
  Memory usage: 5%                IPv4 address for eth0: 139.59.143.140
  Swap usage:   0%                IPv4 address for eth0: 10.19.0.5

Expanded Security Maintenance for Applications is not enabled.

72 updates can be applied immediately.
45 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@ubuntu-s-2vcpu-4gb-fra1-01:~# 
```
<br />

**Nexus Installation**

Download the nexus software:
```sh
root@ubuntu-s-2vcpu-4gb-fra1-01:~# cd /opt/
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# wget https://download.sonatype.com/nexus/3/nexus-3.86.0-08-linux-x86_64.tar.gz
--2025-11-06 10:29:56--  https://download.sonatype.com/nexus/3/nexus-3.86.0-08-linux-x86_64.tar.gz
Resolving download.sonatype.com (download.sonatype.com)... 204.236.175.70, 54.176.187.166
Connecting to download.sonatype.com (download.sonatype.com)|204.236.175.70|:443... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: https://cdn.download.sonatype.com/repository/downloads-prod-group/3/nexus-3.86.0-08-linux-x86_64.tar.gz [following]
--2025-11-06 10:29:57--  https://cdn.download.sonatype.com/repository/downloads-prod-group/3/nexus-3.86.0-08-linux-x86_64.tar.gz
Resolving cdn.download.sonatype.com (cdn.download.sonatype.com)... 104.18.1.134, 104.18.0.134, 2606:4700::6812:186, ...
Connecting to cdn.download.sonatype.com (cdn.download.sonatype.com)|104.18.1.134|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 436493027 (416M) [application/x-gzip]
Saving to: ‘nexus-3.86.0-08-linux-x86_64.tar.gz’

nexus-3.86.0-08-linux-x86_64.tar.gz             100%[=====================================================================================================>] 416.27M   258MB/s    in 1.6s    

2025-11-06 10:29:58 (258 MB/s) - ‘nexus-3.86.0-08-linux-x86_64.tar.gz’ saved [436493027/436493027]
```
<br />

Extract tarball file i the /opt directory:
```sh
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# tar xvzf nexus-3.86.0-08-linux-x86_64.tar.gz 
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# ls -lrth
total 417M
drwxr-xr-x 3 root root 4.0K Nov  3 23:12 sonatype-work
-rw-r--r-- 1 root root 417M Nov  5 15:28 nexus-3.86.0-08-linux-x86_64.tar.gz
drwxr-xr-x 4 root root 4.0K Nov  6 09:48 digitalocean
drwxr-xr-x 6 root root 4.0K Nov  6 10:30 nexus-3.86.0-08
```
Create "nexus" user that will be used to start Nexus service as we don't want to make security risk and start it as a root user:
```sh
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# useradd -m -c "Nexus Software User" -s /bin/bash nexus
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# passwd nexus
New password: 
Retype new password: 
passwd: password updated successfully
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# getent passwd nexus
nexus:x:1000:1000:Nexus Software User:/home/nexus:/bin/bash
```
Change ownership on sonatype-work and nexus* directories using recursive parameter:
```sh
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# chown -R nexus:nexus sonatype-work/
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# chown -R nexus:nexus nexus-3.86.0-08
```
Create nexus.rc file to define user which will be used to start nexus and start the service:
```sh
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# ls -lrth nexus-3.86.0-08/bin/ && cat nexus-3.86.0-08/bin/nexus.rc
total 255M
-rw-r--r-- 1 nexus nexus 1.3K Nov  3 22:38 nexus.vmoptions
-rwxr-xr-x 1 nexus nexus 6.6K Nov  3 22:38 nexus
-rw-r--r-- 1 nexus nexus 255M Nov  3 23:09 sonatype-nexus-repository-3.86.0-08.jar
-rwxr-xr-x 1 nexus nexus   22 Nov  6 10:37 nexus.rc
start_as_user="nexus"
```
Install java 17:
```sh
root@ubuntu-s-2vcpu-4gb-fra1-01:/opt# java --version
openjdk 17.0.16 2025-07-15
OpenJDK Runtime Environment (build 17.0.16+8-Ubuntu-0ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 17.0.16+8-Ubuntu-0ubuntu124.04.1, mixed mode, sharing)
```
Start the nexus service as nexus user:
```sh
nexus@ubuntu-s-2vcpu-4gb-fra1-01:/opt/nexus-3.86.0-08/bin$ ./nexus start
Starting nexus
nexus@ubuntu-s-2vcpu-4gb-fra1-01:/opt/nexus-3.86.0-08/bin$ ps -ef | grep -i nexus
root        3402    2140  0 10:40 pts/0    00:00:00 sudo su - nexus
root        3403    3402  0 10:40 pts/1    00:00:00 sudo su - nexus
root        3404    3403  0 10:40 pts/1    00:00:00 su - nexus
nexus       3405    3404  0 10:40 pts/1    00:00:00 -bash
nexus       3666       1 99 10:41 pts/1    00:00:03 /opt/nexus-3.86.0-08/jdk/temurin_17.0.13_11_linux_x86_64/jdk-17.0.13+11/bin/java -server -Dnexus.installer.type=linux-x86-64 -Xms2703m -Xmx2703m -XX:+UnlockDiagnosticVMOptions -XX:+LogVMOutput -XX:LogFile=../sonatype-work/nexus3/log/jvm.log -XX:-OmitStackTraceInFastThrow -Dkaraf.home=. -Dkaraf.base=. -Djava.util.logging.config.file=etc/spring/java.util.logging.properties -Dkaraf.data=../sonatype-work/nexus3 -Dkaraf.log=../sonatype-work/nexus3/log -Djava.io.tmpdir=../sonatype-work/nexus3/tmp -Djdk.tls.ephemeralDHKeySize=2048 -Dfile.encoding=UTF-8 --add-reads=java.xml=java.logging --add-opens java.base/java.security=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.naming/javax.naming.spi=ALL-UNNAMED --add-opens java.rmi/sun.rmi.transport.tcp=ALL-UNNAMED --add-exports=java.base/sun.net.www.protocol.http=ALL-UNNAMED --add-exports=java.base/sun.net.www.protocol.https=ALL-UNNAMED --add-exports=java.base/sun.net.www.protocol.jar=ALL-UNNAMED --add-exports=jdk.xml.dom/org.w3c.dom.html=ALL-UNNAMED --add-exports=jdk.naming.rmi/com.sun.jndi.url.rmi=ALL-UNNAMED --add-exports=java.security.sasl/com.sun.security.sasl=ALL-UNNAMED --add-exports=java.base/sun.security.x509=ALL-UNNAMED --add-exports=java.base/sun.security.rsa=ALL-UNNAMED --add-exports=java.base/sun.security.pkcs=ALL-UNNAMED -jar /opt/nexus-3.86.0-08/bin/sonatype-nexus-repository-3.86.0-08.jar
```
After I logged in, changed default password and set up my nexus I can create new docker image repository.

**Create Docker repository**

I created "docker-demo-project" repository with the following specifications:
- http port 7070
- default blob storage

![nexus-repo](docker-demo-project-repo.png)
<br />

I also created role for this repository and user as well:
![docker-demo-role](docker-demo-role.png)
<br />

![docker-demo-user](docker-demo-user.png)

**Push Docker Image to the Nexus repository**

Tag the image:
```sh
armin@nb-pf565v12:~$ docker tag demo-docker-app:1.0 139.59.143.140:7070/docker-demo-project:1.0
```
Because my Nexus repository for docker is plan http (not https), I have to add my repository as insecure repository in the /etc/docker/daemon.json file. After thet docker.service needs to be restarted and login should work:
```sh
armin@nb-pf565v12:~$ cat /etc/docker/daemon.json
{
  "insecure-registries": [
	  "192.168.0.112:5000",
	  "devops-nexus:5000",
	  "192.168.0.112:8083",
	  "192.168.0.112:7070",
	  "192.168.0.112:3031",
	  "devops-nexus:7070",
	  "139.59.143.140:7070"
  ]
}

armin@nb-pf565v12:~$ systemctl --user restart docker.service
armin@nb-pf565v12:~$ docker login 139.59.143.140:7070
Username: dockerdemo
Password: 

WARNING! Your credentials are stored unencrypted in '/home/armin/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
```
Now we can push our Docker Image to the repository:
```sh
armin@nb-pf565v12:~$ docker push 139.59.143.140:7070/docker-demo-project:1.0
The push refers to repository [139.59.143.140:7070/docker-demo-project]
694fa2a956de: Pushed 
5f70bf18a086: Pushed 
efa19e510c86: Pushed 
aad6d01c8ba2: Pushed 
8bc61164599f: Pushed 
a81608eb20af: Pushed 
1548c3f692a1: Pushed 
256f393e029f: Pushed 
1.0: digest: sha256:4f3069f04b1df6dff9bd3ad1920387a4570c4a8cef7eec39a656ffed1fee2f81 size: 1992
```
![docker-image-pushed](docker-demo-image-pushed.png)

</details>

******

<details>
<summary>Project: Deploy Nexus as Docker container</summary>
<br />


