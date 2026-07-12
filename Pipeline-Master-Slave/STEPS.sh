sudo apt update && apt install -y unzip jq net-tools
apt install openjdk-21-jdk -y
apt install maven -y && curl https://get.docker.com | bash
useradd -G docker adminAnkit
usermod -aG docker adminAnkit

# aws cli install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# # azurecli ubuntu install
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# terraform.io and packer.io copy the link and install in /usr/local/bin

cd /usr/local/bin
wget https://releases.hashicorp.com/terraform/1.15.8/terraform_1.15.8_linux_amd64.zip
unzip terraform_1.15.8_linux_amd64.zip

# packer.io
wget https://releases.hashicorp.com/packer/1.15.4/packer_1.15.4_linux_amd64.zip
unzip packer_1.15.4_linux_amd64.zip

# document.ansible.com  Select ubuntu and download the file accordingly
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

cd /etc/ansible
cp ansible.cfg ansible.cfg_backup
ansible-config init --disabled >ansible.cfg
nano ansible.cfg

ctrl w  host_key_checking = False

# Create one ansible user.
sudo useradd -m -s /bin/bash ansibleadmin
sudo mkdir -p /home/ansibleadmin/.ssh
sudo chown -R ansibleadmin:ansibleadmin /home/ansibleadmin/.ssh
sudo chmod 700 /home/ansibleadmin/.ssh
sudo touch /home/ansibleadmin/.ssh/authorized_keys
sudo chown ansibleadmin:ansibleadmin /home/ansibleadmin/.ssh/authorized_keys
sudo chmod 600 /home/ansibleadmin/.ssh/authorized_keys
sudo usermod -aG sudo ansibleadmin
echo 'ansibleadmin ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
echo 'ssh-rsa key here' | sudo tee /home/ansibleadmin/.ssh/authorized_keys
usermod -aG root ansibleadmin
usermod -aG docker ansibleadmin

# Install trivy https://github.com/aquasecurity/trivy/releases/download/v0.41.0/trivy_0.41.0_Linux-64bit.deb

cd /usr/local/bin
wget https://github.com/aquasecurity/trivy/releases/download/v0.72.0/trivy_0.72.0_Linux-64bit.deb
dpkg -i trivy_0.72.0_Linux-64bit.deb
trivy --version

#################################

# 1 reboot the system for configurations, Once it is up then take AMI image and wait till the image has been created. Then install jenkins.
# 2 Create DNS Record for Jenkins Jfrog and Sonarqube, Turn the sonar jfrog instance.

#################################

#jenkins installation

# # Add Jenkins GPG keyl
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | \
# sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null
# # Add Jenkins repository to sources list
# echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

# # Update package list
# sudo apt-get update

# # (Optional) Check available Jenkins versions
# sudo apt-cache madison jenkins | grep -i 2.426.2

# # Install the specific Jenkins version
# sudo apt-get install jenkins=2.426.2 -y


sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins



######################################################################################################################

Login and install all neccessary plugins

PLugins

- Pipeline: AWS Steps
- Docker Plugin
- SonarQube Scanner Version 2.15 and configure it in Jenins Configure System.
- Blue Ocean
- Multibranch Scan Webhook Trigger
- Slack Notification
- Ansible

Once done, reboot the jenkins server

sudo systemctl restart jenkins


Then update the SSL certificate following below.

#######################################################################################################################

# SSL Certificate
snap install --classic certbot

certbot certonly --manual --preferred-challenges=dns --key-type rsa \
    --email ankit.bhange123@gmail.com --server https://acme-v02.api.letsencrypt.org/directory \
    --agree-tos -d "*.komaldevops.xyz"

#get into the  /etc/letsencrypt/live/komaldevops.xyz/ Then run below, Because it needs to pick the crts.

openssl pkcs12 -inkey privkey.pem -in cert.pem -export -out certificate.p12

# password : Bhange@123

#Now convert into JKS certificate,
keytool -importkeystore -srckeystore certificate.p12 -srcstoretype pkcs12 \
    -destkeystore jenkinsserver.jks -deststoretype JKS
  
# password : Bhange@123

sudo cp jenkinsserver.jks /var/lib/jenkins/
sudo chown jenkins:jenkins /var/lib/jenkins/jenkinsserver.jks

nano /lib/systemd/system/jenkins.service

Environment="JENKINS_PORT=8080"
Environment="JENKINS_PORT=8080"
Environment="JENKINS_HTTPS_PORT=8443"
Environment="JENKINS_HTTPS_KEYSTORE=/var/lib/jenkins/jenkinsserver.jks"
Environment="JENKINS_HTTPS_KEYSTORE_PASSWORD=Bhange@123"
AmbientCapabilities=CAP_NET_BIND_SERVICE

echo 'JENKINS_ARGS="$JENKINS_ARGS --httpsPort=8443 --httpPort=-1 --httpsPrivateKey=/etc/letsencrypt/live/komaldevops.xyz/privkey.pem --httpsCertificate=/etc/letsencrypt/live/komaldevops.xyz/fullchain.pem"' >>/etc/default/jenkins

sudo usermod -aG docker jenkins
sudo usermod -aG root jenkins
sudo systemctl daemon-reload && sudo systemctl restart jenkins && sudo systemctl status jenkins

## Our Jenkins Server is ready now ... Installation part is done

## Integration we have to do 
Step 1 create two agents (slaves) give name to jenkins-agent-prod and jenkins-agent-dev.
  
Manage Jenkins > Credentials > System > Global Credentials.

Add new credentials:
ID: Agent-Access
Description: Agent-Access
Username: ubuntu
Password: Use your .pem file.

Deploy the agents on t2.medium by using AMI we have created.

Step 2: Now adding this agent to jenkins controller (Making controller-agent Architecture)

Navigate to Manage Jenkins > Nodes > Add Node.
Configure Dev-Slave:
Permanent Agent: Yes
Description Responsible for pushing code into dev-environment.
No. of Executors: 2
Remote Root Directory: /home/ubuntu
Labels: DEV
Usage: Only build jobs with label expressions matching this node.
Launch Method: Launch Agents via SSH
Host: Dev slave private IP or DNS
Credentials: ubuntu (Agent-Access)
Host Key Verification Strategy: Non-verifying strategy
Port: 22
Repeat the same steps for prod-agent, copying settings from dev-Slave but updating the names and IP/DNS accordingly.

Step 3: Making Handshake between Github and Jenkins:

##Switch to the Jenkins user:
su - jenkins
ssh-keygen
## Add the private key to Jenkins:
## Navigate to Manage Jenkins > Credentials > System > Global Credentials.
## Add SSH Username with Private Key:
ID: GitHubAccess
Username: jenkins
Private Key: Paste the generated private key.
Add the public key to your GitHub repository under Deploy Keys.

Step4. Configure SonarQube

Generate a token from SonarQube:
Navigate to SonarQube > My Account > Security.
Generate a token and copy it.
Add the token to Jenkins:
Navigate to Manage Jenkins > Credentials > System > Global Credentials.
Add Secret Text:
ID: sonarqube-token
Scope: Global
Secret: Paste the token.
Configure SonarQube in Jenkins:
Navigate to Manage Jenkins > System > Configure System.
Add SonarQube Server:
Name: As per your script
URL: Your SonarQube URL (remove trailing slash)
Credentials: Select the token you just created.
Create a webhook in SonarQube:
Navigate to Administrator > Webhooks > Create.
Name: Jenkins-Webhook
URL: http://<Jenkins-Master-PublicIP>:8080/sonarqube-webhook/


Step 5. Configure GitHub Webhooks

Push your development code to a private GitHub repository.
Navigate to Repository Settings > Webhooks > Add Webhook.
Content Type: application/json
URL: As per your Jenkins pipeline token.
Add the webhook and authenticate it.

Step 6. Create a Multibranch Pipeline

Create a new item in Jenkins:
Name: Your pipeline name
Type: Multibranch Pipeline
Configure the pipeline:
Branch Source:
Type: Git
Credentials: Jenkins (GitHubAccess)
Repository URL: Your GitHub repository URL
Build Configuration:
Script Path: Jenkinsfile
Scan by Webhook: Use the same token as the GitHub webhook.
Add the public SSH key generated earlier to GitHub Deploy Keys.

Step 7. Configure Slack Notifications

Create a Slack channel and add the Jenkins app:
Channel: Your desired Slack channel.
Token: Copy the integration token.
Add the Slack token to Jenkins:
Navigate to Manage Jenkins > Credentials > System > Global Credentials.
Add Secret Text:
ID: slack-token
Secret: Paste the token.
Configure Slack in Jenkins:
Navigate to Manage Jenkins > System.
Add Slack configuration:
Workspace: Your Slack workspace name
Credentials: Select slack-token
Channel: Your Slack channel name

Step 8. Additional Steps

Update the settings.xml file with the correct JFrog URL.
Assign an IAM role with admin access to Jenkins for pushing reports.
Configure labels for nodes:
Manage Jenkins > Nodes and Clouds > Built-in Node:
Labels: MASTER

Step 9. Test the Setup

Create a new branch (development) in GitHub.
Push a commit to the branch.
Check if the pipeline triggers and runs successfully in Blue Ocean.
Create a prod branch and run the job on the Prod-Slave node.

Step 10. Stopping Instances

Stop all instances when not in use but do not terminate them to preserve configurations.

