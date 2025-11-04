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
```
