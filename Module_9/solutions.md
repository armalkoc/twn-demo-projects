<details>
<summary>Deploy Web Application on EC2 Instance (manually)</summary>
<br />

**Create and configure an EC2 Instance on AWS**

I created EC2 instance using AWS UI but these are it's main parameters:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-instances --filters "Name=tag:project, Values=aws-demo" --query "Reservations[].Instances[].Tags[]"
[
    {
        "Key": "Name",
        "Value": "aws-demo"
    },
    {
        "Key": "project",
        "Value": "aws-demo"
    }
]
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-instances --filters "Name=tag:project, Values=aws-demo" --query "Reservations[].ReservationId"
[
    "r-0a1206c8880627fee"
]
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-instances --filters "Name=tag:project, Values=aws-demo" --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.AttachTime"
[
    "2025-11-13T13:12:03+00:00"
]
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-instances --filters "Name=tag:project, Values=aws-demo" --query "Reservations[].Instances[].NetworkInterfaces[].Groups"
[
    [
        {
            "GroupId": "sg-018a280e14383c223",
            "GroupName": "secutrity-group-aws-demo-project"
        }
    ]
]
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-instances --filters "Name=tag:project, Values=aws-demo" --query "Reservations[].Instances[].NetworkInterfaces[].SubnetId"
[
    "subnet-0c70fadcee6a460a2"
]
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-instances --filters "Name=tag:project, Values=aws-demo" --query "Reservations[].Instances[].NetworkInterfaces[].VpcId"
[
    "vpc-0f1f9593638b5d36e"
]
```
Security group was created as well and it has following permissions:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-security-groups --group-ids sg-018a280e14383c223 --query "SecurityGroups[].GroupName"
[
    "secutrity-group-aws-demo-project"
]

armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-security-groups --group-ids sg-018a280e14383c223 --query "SecurityGroups[].IpPermissions"
[
    [
        {
            "IpProtocol": "tcp",
            "FromPort": 8080,
            "ToPort": 8080,
            "UserIdGroupPairs": [],
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "Ipv6Ranges": [],
            "PrefixListIds": []
        },
        {
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "UserIdGroupPairs": [],
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "Ipv6Ranges": [],
            "PrefixListIds": []
        }
    ]
]
```
NOTE: Port 8080 was opened since it will be needed to acces our application through web browser on port 8080.

VPC details:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-vpcs --vpc-ids vpc-0f1f9593638b5d36e
{
    "Vpcs": [
        {
            "OwnerId": "647797471572",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-078a765bacad0539a",
                    "CidrBlock": "172.31.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": true,
            "BlockPublicAccessStates": {
                "InternetGatewayBlockMode": "off"
            },
            "VpcId": "vpc-0f1f9593638b5d36e",
            "State": "available",
            "CidrBlock": "172.31.0.0/16",
            "DhcpOptionsId": "dopt-0f44fd17e1640b329"
        }
    ]
}
```
Subnet details:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-subnets --subnet-ids subnet-0c70fadcee6a460a2
{
    "Subnets": [
        {
            "AvailabilityZoneId": "euc1-az3",
            "MapCustomerOwnedIpOnLaunch": false,
            "OwnerId": "647797471572",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "SubnetArn": "arn:aws:ec2:eu-central-1:647797471572:subnet/subnet-0c70fadcee6a460a2",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            },
            "BlockPublicAccessStates": {
                "InternetGatewayBlockMode": "off"
            },
            "SubnetId": "subnet-0c70fadcee6a460a2",
            "State": "available",
            "VpcId": "vpc-0f1f9593638b5d36e",
            "CidrBlock": "172.31.32.0/20",
            "AvailableIpAddressCount": 4090,
            "AvailabilityZone": "eu-central-1b",
            "DefaultForAz": true,
            "MapPublicIpOnLaunch": true
        }
    ]
}
```
<br />

**Install Docker on remote EC2 Instance**

Docker has been installed on my EC2 instance and ec2-user was added to the docker group
```sh
[ec2-user@ip-172-31-34-132 ~]$sudo yum install docker.io
[ec2-user@ip-172-31-34-132 ~]$ groups
ec2-user adm wheel systemd-journal docker
[ec2-user@ip-172-31-34-132 ~]$ docker -v
Docker version 25.0.13, build 0bab007

[ec2-user@ip-172-31-34-132 ~]$ systemctl enable docker
[ec2-user@ip-172-31-34-132 ~]$ systemctl start docker

[ec2-user@ip-172-31-34-132 ~]$ sudo usermod -aG docker ec2-user
```
<br />

**Deploy Docker image from private Docker repository on EC2 Instance**

In this demo project I use this repository (master branch) for my java-maven app https://gitlab.com/twn-armin/jenkins-demo-project/java-maven-app.git .

Shared Library is in this repository - https://gitlab.com/twn-armin/jenkins-demo-project/demo-project-shared-library.git .

After Jenkins Job was executed, Docker Image was pushed to the DockerHub private repository:
<br />

![dockerhub-private-repo](dockerhub-private-repo.png)

In the nex step I manually run Docker Container using following command:
```sh
[ec2-user@ip-172-31-34-132 ~]$ docker .run -d -p 8080:8080 --name maven-app amalkoc/jenkins-demo:1.1.16-14
```

Since my security group was already configured to allow inbound traffin on port 8080, I can access to my app through web UI:
<br />

![maven-app-access](maven-app-access.png)
<br />

</details>

******

<details>
<summary>Project: CD - Deploy Application from Jenkins Pipeline to EC2 Instance (automatically with docker)</summary>
<br />

**Prepare AWS EC2 Instance for deployment (Install Docker)**

I alredy installed Docker in previous Project:
```sh
[ec2-user@ip-172-31-34-132 ~]$ docker -v
Docker version 25.0.13, build 0bab007
```
<br />

**Create ssh key credentials for EC2 server on Jenkins**

First of all I've installed "ssh agent" plugin in Jenkins. After that I created credentials using value of my .pem file for EC2 instance:
<br />

![ec2-user-key](ec2-user-key.png)

**Extend the previous CI pipeline with deploy step to ssh into the remote EC2 instance and deploy newly built image from Jenkins  server**
<br />

Jenkinsfile - https://gitlab.com/twn-armin/jenkins-demo-project/java-maven-app/-/blob/master/Jenkinsfile?ref_type=heads

In my previous Jenkinsfile I added deployment step with when expression since I want to do build and deploy just for master branch:
```groovy
stage("Deploy Docker Image to the AWS EC2 instance") {
    when {
        expression {
            BRANCH_NAME == 'master'
            }
        }
        steps {
            script {
                echo "Deploy Docker Image to AWS EC2"
                def dockerCmd = 'docker run -d -p 8080:8080 --name maven-app amalkoc/jenkins-demo:1.1.16-14'
                def user = 'ec2-user'
                def srvIP = '35.158.118.115'
                sshagent(['ec2-user-key']) {
                    sh "ssh -o StrictHostKeyChecking=no ${user}@${srvIP} ${dockerCmd}"
            }
        }
    }
}
```
<br />

**Configure security group on EC2 Instance to allow access to our web application**

I configured my security group to enable access to my web app using port 8080:

![ec2-sg-access](ec2-sg-access.png)
<br />

</details>

******

<details>
<summary>Project: CD - Deploy Application from Jenkins Pipeline on EC2 Instance (automatically with docker-compose)</summary>
<br />

**Install Docker Compose on AWS EC2 Instance**
```sh
[ec2-user@ip-172-31-34-132 ~]$ sudo curl -SL https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 73.0M  100 73.0M    0     0   158M      0 --:--:-- --:--:-- --:--:--  158M

[ec2-user@ip-172-31-34-132 ~]$ sudo chmod +x /usr/local/bin/docker-compose
[ec2-user@ip-172-31-34-132 ~]$ docker-compose -v
Docker Compose version v2.40.3
```
**Create docker-compose.yml file that deploys our web application image**

Java-Maven Repository with all the files - https://gitlab.com/twn-armin/jenkins-demo-project/java-maven-app/-/tree/master?ref_type=heads

I created following docker-compose.yaml file:
```yaml
version: '3'
services:
  maven-app:
    image: amalkoc/jenkins-demo:$IMAGE
    container_name: maven-app
    ports:
      - 8080:8080
```
<br />

**Configure Jenkins pipeline to deploy newly built image using Docker Compose on EC2 server**

I reconfigured deploy step in my Jenkisfile like this:
```groovy
stage("Deploy Docker Image to the AWS EC2 instance") {
    when {
        expression {
            BRANCH_NAME == 'master'
            }
        }
    steps {
        script {
            echo "Deploy Docker Image to AWS EC2"
            //def dockerCmd = 'docker run -d -p 8080:8080 --name maven-app amalkoc/jenkins-demo:1.1.16-14'
            def dockerCmd = "bash ./server-cmds.sh ${env.IMAGE_NAME}"
            def user = 'ec2-user'
            def userHome = '/home/ec2-user'
            def srvIP = '35.158.118.115'
            sshagent(['ec2-user-key']) {
                sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${user}@${srvIP}:${userHome}"
                sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${user}@${srvIP}:${userHome}"
                sh "ssh -o StrictHostKeyChecking=no ${user}@${srvIP} ${dockerCmd}"
            }
        }
    }
}
```
<br />

**Improvement: Extract multiple Linux commands that are executed on remote server into a separate shell script and execute the script from Jenkinsfile**

I created new shell script "server-cmds.sh" that is being executed from the Jenkinsfile as you can se above:
```sh
export IMAGE=$1
docker-compose -f docker-compose.yaml up -d
echo "success"
```
NOTE: I also extracted all the logic of deployment step from Jenkinsfile to shared library vars/appDeploy.groovy. You can find repositories here:

java-maven-app - https://gitlab.com/twn-armin/jenkins-demo-project/java-maven-app/-/tree/master?ref_type=heads
<br />
shared library - https://gitlab.com/twn-armin/jenkins-demo-project/demo-project-shared-library.git

</details>

******

<details>
<summary>Project: Complete the CI/CD Pipeline (Docker-Compose, Dynamicversioning)</summary>
<br />

All the steps are done and you can check it using these repositories:

- java-maven-app - https://gitlab.com/twn-armin/jenkins-demo-project/java-maven-app/-/tree/master?ref_type=heads
- shared library - https://gitlab.com/twn-armin/jenkins-demo-project/demo-project-shared-library
<br />

</details>

******

<details>
<summary>Project: Interacting with AWS CLI</sumary>
<br />

**Install and configure AWS CLI tool to connect to our AWS account**

I installed AWS Client using official installation guide - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html .
```sh
armin@nb-pf565v12:~$ aws --version
aws-cli/2.31.23 Python/3.13.7 Linux/6.8.0-51-generic exe/x86_64.linuxmint.22
```sh
After that AWS CLI has been configured to use admin access key:
```sharmin@nb-pf565v12:~/Downloads/aws$ ls -lrth
total 16K
-rw-rw-r-- 1 armin armin 110 Oct 21 16:50 admin_credentials.csv
-rw-rw-r-- 1 armin armin  99 Oct 21 17:06 admin_accessKeys.csv
-rw-rw-r-- 1 armin armin 116 Oct 30 10:17 armin_credentials.csv
-rw-rw-r-- 1 armin armin 254 Oct 30 11:30 armin_acc_key.txt
armin@nb-pf565v12:~/Downloads/aws$ aws configure list
NAME       : VALUE                    : TYPE             : LOCATION
profile    : <not set>                : None             : None
access_key : ****************FLUK     : shared-credentials-file : 
secret_key : ****************TYDs     : shared-credentials-file : 
region     : eu-central-1             : config-file      : ~/.aws/config
```
<br />

**Create EC2 Instance using the AWS CLI with all necessary configurations like Security Group**

**Create VPC with 1 Subnet**

Create VPC and retut VPC ID:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-vpc --cidr-block 172.16.0.0/16 --query "Vpc.VpcId" --output text
vpc-0f97169462ff9b16e
```
Create Subnet in the VPC:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-subnet --vpc-id vpc-0f97169462ff9b16e --cidr-block 172.16.1.0/24
{
    "Subnet": {
        "AvailabilityZoneId": "euc1-az2",
        "MapCustomerOwnedIpOnLaunch": false,
        "OwnerId": "647797471572",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "SubnetArn": "arn:aws:ec2:eu-central-1:647797471572:subnet/subnet-07a3270f38aafead9",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-07a3270f38aafead9",
        "State": "available",
        "VpcId": "vpc-0f97169462ff9b16e",
        "CidrBlock": "172.16.1.0/24",
        "AvailableIpAddressCount": 251,
        "AvailabilityZone": "eu-central-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}
```
Return Subnet ID:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0f97169462ff9b16e" --query Subnets[].SubnetId --output text
subnet-07a3270f38aafead9
```

**Make our subnet public by attaching it internet gateway**

Create internet-gateway to allow access to external network from our subnet and VPC:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text
igw-052a620f767b284d3
```
Attach internet-gateway to the vpc:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 attach-internet-gateway --internet-gateway-id igw-052a620f767b284d3 --vpc-id vpc-0f97169462ff9b16e
```
Create route table for our VPC:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-route-table --vpc-id vpc-0f97169462ff9b16e --query RouteTable.RouteTableId --output text
rtb-02beebe55de7aa681
```
Create Route rule for handling all traffic between internet and our VPC:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-route --route-table-id rtb-02beebe55de7aa681 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-052a620f767b284d3
{
    "Return": true
}
```
Valide that our custom route table has correct configuraton, 1 local and 1 interent gateway routes:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 describe-route-tables --route-table-id rtb-02beebe55de7aa681
{
    "RouteTables": [
        {
            "Associations": [],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-02beebe55de7aa681",
            "Routes": [
                {
                    "DestinationCidrBlock": "172.16.0.0/16",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                },
                {
                    "DestinationCidrBlock": "0.0.0.0/0",
                    "GatewayId": "igw-052a620f767b284d3",
                    "Origin": "CreateRoute",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-0f97169462ff9b16e",
            "OwnerId": "647797471572"
        }
    ]
}
```
Associate subnet with the route table we've just created to allow internet traffic in the subnet as well:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 associate-route-table --route-table-id rtb-02beebe55de7aa681 --subnet-id subnet-07a3270f38aafead9
{
    "AssociationId": "rtbassoc-00639140864dc0830",
    "AssociationState": {
        "State": "associated"
    }
}
```

**Create security group in the VPC to allow access on port 22**

Create Security Group:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-security-group --group-name AWSDemoProject --description "Security group for AWS Demo Project" --vpc-id vpc-0f97169462ff9b16e
{
    "GroupId": "sg-0f10b404d26261ebd",
    "SecurityGroupArn": "arn:aws:ec2:eu-central-1:647797471572:security-group/sg-0f10b404d26261ebd"
}
```

Add incoming access on port 22 from all sources to security group:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 authorize-security-group-ingress --group-id sg-0f10b404d26261ebd --protocol tcp --port 22 --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-025cb4c1043a3eea1",
            "GroupId": "sg-0f10b404d26261ebd",
            "GroupOwnerId": "647797471572",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:eu-central-1:647797471572:security-group-rule/sgr-025cb4c1043a3eea1"
        }
    ]
}
```
**Create SSH key pair**
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws ec2 create-key-pair --key-name AWSDemoProject --query "KeyMaterial" --output text >> AWSDemoProjectKeyPair.pem
armin@nb-pf565v12:~/Downloads/aws$ chmod 400 AWSDemoProjectKeyPair.pem 
armin@nb-pf565v12:~/Downloads/aws$ mv AWSDemoProjectKeyPair.pem ~/.ss
.ssh/ .ssr/ 
armin@nb-pf565v12:~/Downloads/aws$ mv AWSDemoProjectKeyPair.pem ~/.ss
.ssh/ .ssr/ 
armin@nb-pf565v12:~/Downloads/aws$ mv AWSDemoProjectKeyPair.pem ~/.ssh/
armin@nb-pf565v12:~/Downloads/aws$ ls -lrth ~/.ssh/
total 100K
-rw------- 1 armin armin  32K Nov 13 14:21 known_hosts.old
-rw------- 1 armin armin  32K Nov 13 14:22 known_hosts
-r-------- 1 armin armin 1,7K Nov 16 17:02 AWSDemoProjectKeyPair.pem
```

**Create EC2 Instance**
```sh
aws ec2 run-instances --image-id ami-089a7a2a13629ecc4 --instance-type t3.micro --security-group-ids sg-0f10b404d26261ebd \
--subnet-id subnet-07a3270f38aafead9 --count 1 \
--key-name AWSDemoProject --associate-public-ip-address
```
We can test if our .pem key works fine and connect to the newly created EC2 instance:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ ssh -i /home/armin/.ssh/AWSDemoProjectKeyPair.pem ec2-user@3.79.228.157
The authenticity of host '3.79.228.157 (3.79.228.157)' can't be established.
ED25519 key fingerprint is SHA256:vTBCDI8cWix61sXYMOnz8Qy1BIsbHyQFVCelqBuZrNw.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.79.228.157' (ED25519) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-172-16-1-182 ~]$
```

**Create IAM resources like User, Group, Policy using the AWS CLI**

Create a new IAM user using random name with UI and CLI access:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws iam create-user --user-name aws-demo
{
    "User": {
        "Path": "/",
        "UserName": "aws-demo",
        "UserId": "AIDAZNU547FKMT5NKPYTP",
        "Arn": "arn:aws:iam::647797471572:user/aws-demo",
        "CreateDate": "2025-11-16T19:06:31+00:00"
    }
}
```
 Create group for user:
 ```sh
 armin@nb-pf565v12:~/Downloads/aws$ aws iam create-group --group-name aws-demo-project
{
    "Group": {
        "Path": "/",
        "GroupName": "aws-demo-project",
        "GroupId": "AGPAZNU547FKHAJ3DEIJO",
        "Arn": "arn:aws:iam::647797471572:group/aws-demo-project",
        "CreateDate": "2025-11-16T19:08:15+00:00"
    }
}
```
Add user to the group:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam add-user-to-group --user-name aws-demo --group-name aws-demo-project
```
We can verify newly created user and group using:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam get-user --user-name aws-demo
{
    "User": {
        "Path": "/",
        "UserName": "aws-demo",
        "UserId": "AIDAZNU547FKMT5NKPYTP",
        "Arn": "arn:aws:iam::647797471572:user/aws-demo",
        "CreateDate": "2025-11-16T19:06:31+00:00"
    }
}
armin@nb-pf565v12:~/Downloads/aws$ aws iam get-group --group-name aws-demo-project
{
    "Users": [
        {
            "Path": "/",
            "UserName": "aws-demo",
            "UserId": "AIDAZNU547FKMT5NKPYTP",
            "Arn": "arn:aws:iam::647797471572:user/aws-demo",
            "CreateDate": "2025-11-16T19:06:31+00:00"
        }
    ],
    "Group": {
        "Path": "/",
        "GroupName": "aws-demo-project",
        "GroupId": "AGPAZNU547FKHAJ3DEIJO",
        "Arn": "arn:aws:iam::647797471572:group/aws-demo-project",
        "CreateDate": "2025-11-16T19:08:15+00:00"
    }
}
```
 **Give user UI and CLI access**

 If we want to provide user with UI and CLI access, we will do the following:
 - create access key 
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws iam create-access-key --user-name aws-demo > aws-demo-access-key.txt
```
- generate login credentials for UI
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam create-login-profile --user-name aws-demo --password MyTestPassword123 --password-reset-required
{
    "LoginProfile": {
        "UserName": "aws-demo",
        "CreateDate": "2025-11-16T19:20:12+00:00",
        "PasswordResetRequired": true
    }
}
```
In order to be able to change password at first login, user must have permission for that:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam list-policies | grep -i password
"PolicyName": "IAMUserChangePassword",
"Arn": "arn:aws:iam::aws:policy/IAMUserChangePassword",
"PolicyName": "IAMCreateRootUserPassword",
"Arn": "arn:aws:iam::aws:policy/root-task/IAMCreateRootUserPassword",

armin@nb-pf565v12:~/Downloads/aws$ aws iam attach-user-policy --user-name aws-demo --policy-arn "arn:aws:iam::aws:policy/IAMUserChangePassword"
```
Now we want to assigne permissions to user through the group to be albe to access on VPC and EC2 instance:
```sh
armin@nb-pf565v12:~/Downloads/aws$ aws iam attach-group-policy --group-name aws-demo-project --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
armin@nb-pf565v12:~/Downloads/aws$ aws iam attach-group-policy --group-name aws-demo-project --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
```
Check policies for the group aws-demo-project:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam list-attached-group-policies --group-name aws-demo-project
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonEC2FullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
        },
        {
            "PolicyName": "AmazonVPCFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
        }
    ]
}
```
**List and browse AWS resources using the AWS CLI**

We can list all the users and groups using the following commands:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam list-users 
{
    "Users": [
        {
            "Path": "/",
            "UserName": "admin",
            "UserId": "AIDAZNU547FKFSMWM3TJK",
            "Arn": "arn:aws:iam::647797471572:user/admin",
            "CreateDate": "2025-10-21T14:49:56+00:00",
            "PasswordLastUsed": "2025-11-16T13:55:00+00:00"
        },
        {
            "Path": "/",
            "UserName": "armin",
            "UserId": "AIDAZNU547FKGNHE4WSKZ",
            "Arn": "arn:aws:iam::647797471572:user/armin",
            "CreateDate": "2025-10-30T09:16:11+00:00",
            "PasswordLastUsed": "2025-10-31T06:55:01+00:00"
        },
        {
            "Path": "/",
            "UserName": "aws-demo",
            "UserId": "AIDAZNU547FKMT5NKPYTP",
            "Arn": "arn:aws:iam::647797471572:user/aws-demo",
            "CreateDate": "2025-11-16T19:06:31+00:00"
        },
        {
            "Path": "/",
            "UserName": "MyUserCli",
            "UserId": "AIDAZNU547FKPFL5JRRLC",
            "Arn": "arn:aws:iam::647797471572:user/MyUserCli",
            "CreateDate": "2025-10-29T10:57:47+00:00",
            "PasswordLastUsed": "2025-10-29T11:32:22+00:00"
        }
    ]
}
armin@nb-pf565v12:~/Downloads/aws$ aws iam list-groups
{
    "Groups": [
        {
            "Path": "/",
            "GroupName": "aws-demo-project",
            "GroupId": "AGPAZNU547FKHAJ3DEIJO",
            "Arn": "arn:aws:iam::647797471572:group/aws-demo-project",
            "CreateDate": "2025-11-16T19:08:15+00:00"
        },
        {
            "Path": "/",
            "GroupName": "devops",
            "GroupId": "AGPAZNU547FKCOIPQ6S3Q",
            "Arn": "arn:aws:iam::647797471572:group/devops",
            "CreateDate": "2025-10-30T09:14:46+00:00"
        },
        {
            "Path": "/",
            "GroupName": "MyGroupCli",
            "GroupId": "AGPAZNU547FKHZSUSTMOT",
            "Arn": "arn:aws:iam::647797471572:group/MyGroupCli",
            "CreateDate": "2025-10-29T10:55:50+00:00"
        }
    ]
}
```
If we want to get info about specific user or group, we will use the following command:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam get-group --group-name aws-demo-project
{
    "Users": [
        {
            "Path": "/",
            "UserName": "aws-demo",
            "UserId": "AIDAZNU547FKMT5NKPYTP",
            "Arn": "arn:aws:iam::647797471572:user/aws-demo",
            "CreateDate": "2025-11-16T19:06:31+00:00"
        }
    ],
    "Group": {
        "Path": "/",
        "GroupName": "aws-demo-project",
        "GroupId": "AGPAZNU547FKHAJ3DEIJO",
        "Arn": "arn:aws:iam::647797471572:group/aws-demo-project",
        "CreateDate": "2025-11-16T19:08:15+00:00"
    }
}
armin@nb-pf565v12:~/Downloads/aws$ aws iam get-user --user-name aws-demo
{
    "User": {
        "Path": "/",
        "UserName": "aws-demo",
        "UserId": "AIDAZNU547FKMT5NKPYTP",
        "Arn": "arn:aws:iam::647797471572:user/aws-demo",
        "CreateDate": "2025-11-16T19:06:31+00:00"
    }
}
```
In order to see policies assigned to the user or group we will use following commands:
```sh 
armin@nb-pf565v12:~/Downloads/aws$ aws iam list-attached-user-policies --user-name aws-demo
{
    "AttachedPolicies": [
        {
            "PolicyName": "IAMUserChangePassword",
            "PolicyArn": "arn:aws:iam::aws:policy/IAMUserChangePassword"
        }
    ]
}
armin@nb-pf565v12:~/Downloads/aws$ aws iam list-attached-group-policies --group-name aws-demo-project
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonEC2FullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
        },
        {
            "PolicyName": "AmazonVPCFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
        }
    ]
}
```
</details>













