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
```
<br />

![nodejs-app](nodejs_app_locally.png)
<br />

But when I try to start nodejs application using in docker container it doesn't work
```sh
docker run -d -p 3000:3000 --name nodejs-app --network twn-demo-docker demo-docker-app:1.0
```

