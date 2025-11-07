<details>
<summary>Project: Install Jenkins on DigitalOcean</summary>
<br />

**Create an Ubuntu server on DigitalOcean**

I have created new Droplet Ubuntu 24.04 LTS instance with the following resources. Also Java, Docker and docker-compose have been installed.
```sh
root@ubuntu-s-1vcpu-2gb-fra1-01:~# cat /etc/os-release 
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
root@ubuntu-s-1vcpu-2gb-fra1-01:~# free -h
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       308Mi       1.1Gi       4.0Mi       655Mi       1.6Gi
Swap:             0B          0B          0B
root@ubuntu-s-1vcpu-2gb-fra1-01:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           197M 1016K  196M   1% /run
/dev/vda1        48G  1.9G   46G   4% /
tmpfs           985M     0  985M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/vda16      881M   61M  758M   8% /boot
/dev/vda15      105M  6.2M   99M   6% /boot/efi
tmpfs           197M   12K  197M   1% /run/user/0
root@ubuntu-s-1vcpu-2gb-fra1-01:~# lscpu | grep -i cpu
CPU op-mode(s):                       32-bit, 64-bit
CPU(s):                               1
root@ubuntu-s-1vcpu-2gb-fra1-01:~# java -version
openjdk version "17.0.16" 2025-07-15
OpenJDK Runtime Environment (build 17.0.16+8-Ubuntu-0ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 17.0.16+8-Ubuntu-0ubuntu124.04.1, mixed mode, sharing)
root@ubuntu-s-1vcpu-2gb-fra1-01:~# docker -v
Docker version 28.2.2, build 28.2.2-0ubuntu1~24.04.1
root@ubuntu-s-1vcpu-2gb-fra1-01:~# docker-compose -v
Docker Compose version v2.40.3
```

**Setup and run Jenkins as Docker Container**

I created named volume for Jenkins container and run the container:

```sh
root@ubuntu-s-1vcpu-2gb-fra1-01:~# docker volume create jenkins-data
jenkins-data
root@ubuntu-s-1vcpu-2gb-fra1-01:~# docker volume ls
DRIVER    VOLUME NAME
local     jenkins-data
```

```sh
root@ubuntu-s-1vcpu-2gb-fra1-01:~# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins -v /var/run/docker.sock:/var/run/docker.sock -v jenkins-data:/var/jenkins_home jenkins/jenkins:lts
Unable to find image 'jenkins/jenkins:lts' locally
lts: Pulling from jenkins/jenkins
cae3b572364a: Pull complete 
11c82e82e8c5: Pull complete 
6d8ebcba18e6: Pull complete 
e29665228ac2: Pull complete 
cc05fa07d253: Pull complete 
7c2b9fc47dae: Pull complete 
9e58f885f660: Pull complete 
51148860bddf: Pull complete 
eba243d676e4: Pull complete 
04e220b291b8: Pull complete 
b9bcce170b58: Pull complete 
606dcc9d6add: Pull complete 
Digest: sha256:f2519b99350faeaaeef30e3b8695cd6261a5d571c859ec37c7ce47e5a241458d
Status: Downloaded newer image for jenkins/jenkins:lts
a6df85ac312f1c8d29a510ea2bba8cfcd7468a0f8027f3c9b2be77627fb226fe

root@ubuntu-s-1vcpu-2gb-fra1-01:~# docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS                                                                                          NAMES
a6df85ac312f   jenkins/jenkins:lts   "/usr/bin/tini -- /u…"   45 seconds ago   Up 43 seconds   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp, 0.0.0.0:50000->50000/tcp, [::]:50000->50000/tcp   jenkins
```
New firewall rule for port 8080 has been configured:
<br />

![jenkins-firewall-rule](jenkins-firewall-rule.png)
<br />

After that I test access to the Jenkins UI and it works fine:
<br />

![jenkins-ui-access](jenkins-ui-access.png)
<br />

Use admin password for first loggin and install suggested plugins:
```sh
root@ubuntu-s-1vcpu-2gb-fra1-01:~# cat /var/lib/docker/volumes/jenkins-data/_data/secrets/initialAdminPassword 
9ac5404de******
```
<br />

![suggested-plugins](suggested-plugins.png)
<br />

Create first admin user and start Jenkins:
<br />

![first-admin-user](first-admin-user.png)