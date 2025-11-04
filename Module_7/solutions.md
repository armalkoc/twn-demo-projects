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
<summary>Dockerize Nodejs application and push to private Docker registry</summary>
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
We can see our Docker Image has been pushed to ECR:
<br />

![ecr-docker-demo](ecr-docker-demo.png)