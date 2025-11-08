## Demo Project: ##
**Install Jenkins on DigitalOcean**

Technologies used: Jenkins, Docker, DigitalOcean, Linux

Project Description:
- Create an Ubuntu server on DigitalOcean
- Set up and run Jenkins as Docker container
- Initialize Jenkins

## Demo Project: ##
Create a CI Pipeline with Jenkinsfile (Freestyle, Pipeline, Multibranch Pipeline)

Technologies used: Jenkins, Docker, Linux, Git, Java, Maven

Project Description:
- CI Pipeline for a Java Maven application to build and push to the repository
- Install Build Tools (Maven, Node) in Jenkins
- Make Docker available on Jenkins server
- Create Jenkins credentials for a git repository
- Create different Jenkins job types (Freestyle, Pipeline, Multibranch pipeline) for the Java Maven project with Jenkinsfile to:
  a. Connect to the application’s git repository
  b. Build Jar
  c. Build Docker Image
  d. Push to private DockerHub repository

## Demo Project: ##
Create a Jenkins Shared Library

Technologies used: Jenkins, Groovy, Docker, Git, Java, Maven

Project Description: Create a Jenkins Shared Library to extract common build logic:
- Create separate Git repository for Jenkins Shared
- Library project
- Create functions in the JSL to use in the Jenkins pipeline
- Integrate and use the JSL in Jenkins Pipeline (globally and for a specific project in Jenkinsfile)

## Demo Project: ##
Configure Webhook to trigger CI Pipeline automatically on every change

Technologies used: Jenkins, GitLab, Git, Docker, Java, Maven

Project Description:
- Install GitLab Plugin in Jenkins
- Configure GitLab access token and connection to Jenkins in GitLab project settings
- Configure Jenkins to trigger the CI pipeline, whenever a change is pushed to GitLab

## Demo Project: ##
Dynamically Increment Application version in Jenkins Pipeline

Technologies used: Jenkins, Docker, GitLab, Git, Java, Maven

Project Description:
- Configure CI step: Increment patch version
- Configure CI step: Build Java application and clean old artifacts
- Configure CI step: Build Image with dynamic Docker Image Tag
- Configure CI step: Push Image to private DockerHub repository
- Configure CI step: Commit version update of Jenkins back to Git repository
- Configure Jenkins pipeline to not trigger automatically on CI build commit to avoid commit loop