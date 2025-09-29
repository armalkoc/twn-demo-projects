#!/bin/bash
# Get the download URL from Nexus Component API
curl -u teamshare:teamshare12 -X GET 'http://devops-nexus:8081/service/rest/v1/components?repository=npm-hosted-repo' | jq "." > artifact_node.json

# Get the donwload URL from the artifact file
artifactdownloadUrl=$(jq -r '.items[].assets[].downloadUrl' artifact_node.json)

# Download the latest node artifact
app="nodejs-app.tgz"
wget --http-user=teamshare --http-password=teamshare12 "$artifactdownloadUrl" -O "$app"

# Extract app and run app
tar -xvzf "$app" && cd package && npm install && node server.js
