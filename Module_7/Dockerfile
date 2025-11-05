FROM node:20-alpine

ENV MONGO_INITDB_ROOT_USERNAME=mongoadmin \
    MONGO_INITDB_ROOT_PASSWORD=mongoadmin123 \
    MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

RUN mkdir /opt/app

COPY ./app /opt/app 

WORKDIR /opt/app 

RUN npm install 

CMD ["node", "server.js"]
