# Jenkins 
<img src="https://spacelift.io/_next/image?url=https%3A%2F%2Fspacelift.io%2Fwp-content%2Fuploads%2F2024%2F07%2Fjenkins-agents.png&w=3840&q=75" width="400" alt="Jenkins Architecture">

In Jenkins, the **Master-Slave** architecture (now more commonly called **Controller-Agent**) is used to distribute build and deployment work across multiple machines.

> **Note:** The older terms *Master* and *Slave* are still widely used in older documentation and interviews, but Jenkins now officially uses **Controller** and **Agent**.

## What is the Controller (Master)?

The **Controller** is the central Jenkins server. It is responsible for:

* Managing Jenkins configuration
* Scheduling jobs
* Maintaining the build queue
* Storing build history and logs
* Managing plugins
* Connecting to agents
* Monitoring agent health

The controller **should not perform heavy builds** in production because that can make Jenkins slow or unavailable.

### Example

Suppose your company has 500 developers pushing code every day.

The controller:

* Receives webhook notifications from GitHub.
* Determines which pipeline should run.
* Assigns the build to an available agent.
* Collects the build results and displays them in the Jenkins UI.

Think of the controller as a **project manager** who assigns work but doesn't do all the coding.

---

## What is an Agent (Slave)?

An **Agent** is a machine (physical, virtual, or container) that executes the jobs assigned by the controller.

Agents can:

* Compile code
* Run unit tests
* Execute integration tests
* Build Docker images
* Deploy applications
* Run security scans

Agents can run on:

* Linux
* Windows
* macOS
* Kubernetes Pods
* Cloud VMs

---

# Production-Level Architecture Example

Imagine an e-commerce company.

```
                  Developers
                       |
                 GitHub Push
                       |
               Jenkins Controller
                       |
        --------------------------------
        |              |              |
    Linux Agent    Windows Agent   Kubernetes Agent
       |                |               |
 Build Java App    Build .NET App   Run Docker Builds
       |                |               |
      Deploy         Run Tests      Deploy to K8s
```

### Why multiple agents?

Different projects need different operating systems.

* Java projects → Linux Agent
* .NET projects → Windows Agent
* iOS projects → macOS Agent
* Docker/Kubernetes workloads → Linux/Kubernetes Agent

---

# Real Production Example (Banking)

Suppose a bank has three applications:

1. Internet Banking (Java)
2. ATM Software (.NET)
3. Mobile Backend (Spring Boot)

They configure Jenkins like this:

### Controller

* Small VM (4 CPU, 8 GB RAM)
* Only schedules jobs
* Stores configuration
* No builds run here

### Linux Agent 1

* Builds Java applications
* Runs Maven
* Executes SonarQube scans

### Linux Agent 2

* Builds Docker images
* Pushes images to the registry
* Deploys to Kubernetes

### Windows Agent

* Builds .NET applications
* Runs Windows-specific tests

### Performance Testing Agent

* Runs load tests using tools like JMeter

Each pipeline runs on the appropriate agent, allowing many builds to happen in parallel.

---

# Example Pipeline

```groovy
pipeline {
    agent { label 'linux-agent' }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
    }
}
```

The controller sees the label `linux-agent` and sends the job to a Linux agent.

---

# Why not build everything on the Controller?

Imagine:

* 200 developers commit code at 9:00 AM.
* Every build takes 15 minutes.
* The controller builds everything itself.

Problems:

* High CPU usage
* Memory exhaustion
* Slow Jenkins UI
* Long build queues
* Increased risk of outages

With agents:

* Jobs run in parallel.
* The controller remains responsive.
* Builds complete faster.

---

# Real Production Scenario

Suppose an organization has:

* 500 developers
* 80 applications
* 300 builds per hour

Their Jenkins setup might include:

* 1 Controller
* 10 Linux Agents
* 3 Windows Agents
* 20 Kubernetes dynamic agents

Flow:

1. A developer pushes code.
2. GitHub triggers Jenkins.
3. The controller receives the webhook.
4. The controller selects an available agent based on labels.
5. The agent checks out the code.
6. The agent builds and tests the application.
7. If successful, the agent deploys it.
8. The agent sends the results back to the controller.
9. The controller updates the build status and notifies the team.

---

## Benefits of Controller-Agent Architecture

* **Scalability:** Add more agents as the number of builds grows.
* **Parallel execution:** Multiple jobs can run simultaneously.
* **Platform flexibility:** Use Linux, Windows, or macOS agents as needed.
* **Resource isolation:** Heavy builds don't affect the controller.
* **High availability:** If one agent fails, jobs can run on another suitable agent.

## Interview Answer (2–3 minutes)

> Jenkins uses a **Controller-Agent architecture**. The **Controller** manages job scheduling, pipeline configuration, plugins, credentials, and the build queue. It delegates the actual execution of jobs to **Agents**, which are separate machines or containers. In production, the controller is kept lightweight while dedicated agents perform builds, tests, Docker image creation, and deployments. For example, a company might use Linux agents for Java applications, Windows agents for .NET applications, and Kubernetes-based agents for containerized workloads. This architecture improves scalability, supports parallel builds, and keeps the Jenkins controller responsive even when handling hundreds of builds per day.

#  ------------------------------------------------

--- 
# STEPS To Create Jenkins Pipeline

It is structured logically, starting with an architecture overview, tool prerequisites, step-by-step controller configuration, SSL/TLS setup, node topology, and pipeline trigger configuration.

```markdown
# Enterprise Production Jenkins CI/CD Pipeline Infrastructure

A complete, battle-tested blueprint for provisioning a multi-branch, multi-node Jenkins Controller-Agent architecture on AWS. This repository covers provisioning base AMIs, configuring enterprise integrations (SonarQube, JFrog, Ansible, Trivy), securing traffic via Let's Encrypt SSL/TLS, and building isolated execution environments for `DEV` and `PROD` workloads.

---

##  Architecture Overview


```

```
                    +----------------------------+
                    |     GitHub Repository      |
                    +--------------+-------------+
                                   |
                           Webhook | (Multibranch Trigger)
                                   v
                 +----------------------------------+
                 |     Jenkins Controller           |
                 |  (SSL/TLS Port 8443, HTTPS)      |
                 +----------------+-----------------+
                                  |
          +-----------------------+-----------------------+
          | SSH (Port 22)                                 | SSH (Port 22)
          v                                               v

```

+---------------------------+                   +---------------------------+
|    Jenkins Agent: DEV     |                   |    Jenkins Agent: PROD    |
| (Label: DEV | Executors: 2)|                   |(Label: PROD | Executors: 2)|
+---------------------------+                   +---------------------------+
|                                               |
+-----------------------+-----------------------+
|
+----------------------------+----------------------------+
|                            |                            |
v                            v                            v
+------------------+        +------------------+        +------------------+
|   SonarQube      |        |   JFrog Artifactory       |     Slack        |
| (Code Quality)   |        | (Artifact Store) |        | (Notifications)  |
+------------------+        +------------------+        +------------------+

```

---

## 🧰 Tech Stack & Tooling

| Category                     | Tools & Services                                          |
| :--------------------------- | :-------------------------------------------------------- |
| **Orchestration**            | Jenkins (Multibranch Pipeline, Blue Ocean)                |
| **Infrastructure & IaC**     | HashiCorp Terraform, HashiCorp Packer, AWS CLI, Azure CLI |
| **Configuration Management** | Ansible                                                   |
| **Security & Quality**       | Aqua Security Trivy, SonarQube                            |
| **Build & Containerization** | OpenJDK 21, Apache Maven, Docker                          |
| **Artifact Management**      | JFrog Artifactory                                         |
| **SSL/TLS & Domain**         | Certbot (Let's Encrypt), OpenSSL, Keytool, Route53 / DNS  |

---

## 🚀 Phase 1: Base AMI Provisioning

Run the following setup script on a baseline Ubuntu instance. This environment serves as the base image for both the Jenkins Controller and Worker Agents.

### 1. Base Package Installation

```bash
# Update repository index & install core network tools
sudo apt update && sudo apt install -y unzip jq net-tools software-properties-common

# Install Java 21, Maven, and Docker Engine
sudo apt install openjdk-21-jdk -y
sudo apt install maven -y
curl -fsSL [https://get.docker.com](https://get.docker.com) | bash

# Create administrative docker user
sudo useradd -G docker adminAnkit
sudo usermod -aG docker adminAnkit

```

### 2. Cloud CLI & HashiCorp Tooling Setup

```bash
# Install AWS CLI v2
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Install Terraform & Packer to /usr/local/bin
cd /usr/local/bin

# Terraform
sudo wget [https://releases.hashicorp.com/terraform/1.15.8/terraform_1.15.8_linux_amd64.zip](https://releases.hashicorp.com/terraform/1.15.8/terraform_1.15.8_linux_amd64.zip)
sudo unzip terraform_1.15.8_linux_amd64.zip
sudo rm terraform_1.15.8_linux_amd64.zip

# Packer
sudo wget [https://releases.hashicorp.com/packer/1.15.4/packer_1.15.4_linux_amd64.zip](https://releases.hashicorp.com/packer/1.15.4/packer_1.15.4_linux_amd64.zip)
sudo unzip packer_1.15.4_linux_amd64.zip
sudo rm packer_1.15.4_linux_amd64.zip

```

### 3. Ansible & Trivy Security Scanner Setup

```bash
# Install Ansible via official PPA
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

# Initialize default Ansible configuration
cd /etc/ansible
sudo cp ansible.cfg ansible.cfg_backup
sudo ansible-config init --disabled > ansible.cfg
# Note: Disable host key checking in /etc/ansible/ansible.cfg (host_key_checking = False)

# Provision dedicated 'ansibleadmin' service user
sudo useradd -m -s /bin/bash ansibleadmin
sudo mkdir -p /home/ansibleadmin/.ssh
sudo touch /home/ansibleadmin/.ssh/authorized_keys

# Configure permissions and sudo privilege escalation
sudo chown -R ansibleadmin:ansibleadmin /home/ansibleadmin/.ssh
sudo chmod 700 /home/ansibleadmin/.ssh
sudo chmod 600 /home/ansibleadmin/.ssh/authorized_keys

sudo usermod -aG sudo,root,docker ansibleadmin
echo 'ansibleadmin ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

# Install Aqua Security Trivy (Vulnerability Scanner)
cd /tmp
wget [https://github.com/aquasecurity/trivy/releases/download/v0.72.0/trivy_0.72.0_Linux-64bit.deb](https://github.com/aquasecurity/trivy/releases/download/v0.72.0/trivy_0.72.0_Linux-64bit.deb)
sudo dpkg -i trivy_0.72.0_Linux-64bit.deb
trivy --version

```

> [!NOTE]
> **Reboot & Bake AMI:** Reboot the server once packages are successfully installed (`sudo reboot`). Take an AWS AMI Snapshot of this instance. Name it `Jenkins-Base-Image-v1`. Use this image to launch your Controller and Worker nodes.

---

## ⚙️ Phase 2: Jenkins Controller Installation & Security

Launch a new instance using the AMI created in Phase 1. Ensure DNS A-Records are configured for Jenkins, JFrog, and SonarQube endpoints before proceeding.

### 1. Install Jenkins LTS

```bash
# Add Jenkins GPG keyring and repository
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc [https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key](https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key)
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] [https://pkg.jenkins.io/debian-stable](https://pkg.jenkins.io/debian-stable) binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y

```

### 2. Mandatory Plugins Installation

Log in to the Jenkins web dashboard (`http://<YOUR_CONTROLLER_IP>:8080`) and install the following plugins via **Manage Jenkins > Plugins**:

* **Pipeline: AWS Steps**
* **Docker Plugin**
* **SonarQube Scanner** (v2.15+)
* **Blue Ocean**
* **Multibranch Scan Webhook Trigger**
* **Slack Notification**
* **Ansible**

Restart Jenkins post-installation: `sudo systemctl restart jenkins`

---

## 🔒 Phase 3: HTTPS & SSL/TLS Configuration

Secure Jenkins using Let's Encrypt Wildcard Certificates converted into a Java Keystore format.

### 1. Issue SSL Certificate via Certbot

```bash
sudo snap install --classic certbot

# Generate Wildcard SSL using DNS Challenge
sudo certbot certonly --manual --preferred-challenges=dns --key-type rsa \
    --email your-email@domain.com \
    --server [https://acme-v02.api.letsencrypt.org/directory](https://acme-v02.api.letsencrypt.org/directory) \
    --agree-tos -d "*.yourdomain.com"

```

### 2. Convert Certificate to PKCS12 & Java Keystore (JKS)

```bash
cd /etc/letsencrypt/live/[yourdomain.com/](https://yourdomain.com/)

# Export to PKCS12
sudo openssl pkcs12 -inkey privkey.pem -in cert.pem -export -out certificate.p12
# Set a strong keystore password when prompted (e.g., KEYSTORE_PASSWORD)

# Convert PKCS12 to JKS
sudo keytool -importkeystore -srckeystore certificate.p12 -srcstoretype pkcs12 \
    -destkeystore jenkinsserver.jks -deststoretype JKS

# Move keystore to Jenkins home directory & set ownership
sudo cp jenkinsserver.jks /var/lib/jenkins/
sudo chown jenkins:jenkins /var/lib/jenkins/jenkinsserver.jks

```

### 3. Update Jenkins Service Configuration

Modify systemd environment settings to enable HTTPS over port `8443`:

```bash
sudo nano /lib/systemd/system/jenkins.service

```

Ensure the following system environment attributes are configured:

```ini
Environment="JENKINS_PORT=-1"
Environment="JENKINS_HTTPS_PORT=8443"
Environment="JENKINS_HTTPS_KEYSTORE=/var/lib/jenkins/jenkinsserver.jks"
Environment="JENKINS_HTTPS_KEYSTORE_PASSWORD=<YOUR_KEYSTORE_PASSWORD>"
AmbientCapabilities=CAP_NET_BIND_SERVICE

```

Add standard startup parameters and apply configuration changes:

```bash
# Assign administrative groups to the jenkins service account
sudo usermod -aG docker,root jenkins

# Reload unit files and restart service
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo systemctl status jenkins

```

---

## 🖥️ Phase 4: Controller-Agent Node Topology

Deploy two dedicated worker nodes on AWS (`t2.medium`) using the custom AMI generated in **Phase 1**.

### Agent Specifications Matrix

| Node Name            | Label  | Role                                                     | Remote Root Directory | Executors |
| -------------------- | ------ | -------------------------------------------------------- | --------------------- | --------- |
| `jenkins-agent-dev`  | `DEV`  | Development builds & automated dynamic integration tests | `/home/ubuntu`        | `2`       |
| `jenkins-agent-prod` | `PROD` | Production deployment execution                          | `/home/ubuntu`        | `2`       |

### Configuration Steps

1. **Add SSH Credentials:**
* Go to **Manage Jenkins > Credentials > System > Global Credentials**.
* Add **SSH Username with private key**:
* **ID:** `Agent-Access`
* **Username:** `ubuntu`
* **Private Key:** Private key (`.pem`) corresponding to the AWS EC2 KeyPair.




2. **Register Agents:**
* Go to **Manage Jenkins > Nodes > New Node**.
* Configure `jenkins-agent-dev` and `jenkins-agent-prod` using SSH launch method, pointing to their respective Private IP addresses.
* Attach label `DEV` to the development node and `PROD` to the production node.



---

## 🔗 Phase 5: Third-Party Tools Integration

### 1. GitHub Integration

* **Controller Keys:** Log in as Jenkins user on controller (`su - jenkins`), execute `ssh-keygen`.
* **Jenkins Credentials:** Store the generated private key as `GitHubAccess`.
* **GitHub Repository:** Add the public key under **Repository Settings > Deploy Keys**.

### 2. SonarQube Integration

* Generate an authentication token in SonarQube (**My Account > Security**).
* Add token in Jenkins Credentials as **Secret Text** with ID `sonarqube-token`.
* Map server configuration under **Manage Jenkins > System > SonarQube Servers**.
* **SonarQube Webhook:** Configure webhook targeting `http://<JENKINS_PUBLIC_IP>:8080/sonarqube-webhook/`.

### 3. GitHub Webhook Trigger

* Configure repository webhook:
* **Payload URL:** `https://jenkins.yourdomain.com:8443/multibranch-webhook-trigger/invoke?token=<YOUR_CUSTOM_TOKEN>`
* **Content Type:** `application/json`
* **Events:** Just the `push` event.



### 4. Slack Notifications

* Install Jenkins app in Slack, select target channel, and record the Integration Token.
* Store token in Jenkins as **Secret Text** with ID `slack-token`.
* Configure Workspace details and Channel mapping under **Manage Jenkins > System > Slack**.

---

## 🧪 Phase 6: Multibranch Pipeline Creation & Testing

1. Navigate to Jenkins Home > **New Item** > Select **Multibranch Pipeline**.
2. **Branch Source:** Select `Git`, add Repository URL, and select `GitHubAccess` credentials.
3. **Build Configuration:** Set Mode to `By Jenkinsfile` (Script Path: `Jenkinsfile`).
4. **Scan Trigger:** Select *Scan by Webhook* and enter the same secret token configured in Step 5.3.

### Verification Workflow

```bash
# 1. Create and switch to development branch
git checkout -b development

# 2. Commit pipeline code and push to GitHub
git add Jenkinsfile
git commit -m "ci: add production enterprise jenkinsfile pipeline"
git push origin development

# 3. Verify execution in Jenkins Blue Ocean UI (Targeting DEV node)
# 4. Merge changes into main/prod branch to verify deployment on PROD node

```

---

> 🛑 **Cost Management Note:** Remember to stop EC2 instances when not actively testing pipeline stages. Do not terminate instances to maintain persistent configurations and IP binding references!

```

---

<ElicitationsGroup message="Next steps to complete your repository:">
  <Elicitation label="Draft a production Jenkinsfile for Java/Maven" query="Provide a complete, production-ready Jenkinsfile using Maven, Docker, Trivy, and SonarQube with stage parallelization."/>
  <Elicitation label="Create an Ansible Playbook for instance setup" query="Write an Ansible playbook that automates all the software installations and user setups detailed in Phase 1."/>
</ElicitationsGroup>

```