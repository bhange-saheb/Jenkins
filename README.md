# Jenkins 
<img src="https://spacelift.io/_next/image?url=https%3A%2F%2Fspacelift.io%2Fwp-content%2Fuploads%2F2024%2F07%2Fjenkins-agents.png&w=3840&q=75" width="600" alt="Jenkins Architecture">

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
