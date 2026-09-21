# Commands Reference

A reference of the commands used by this project's Jenkins Multibranch Pipeline, together with the manual commands used while building, testing, troubleshooting, and validating the system.

The current learning environment runs Jenkins and the application deployment target on the **same AWS EC2 instance**.

Jenkins uses host port `8080`, while the application is exposed on host port `8081` and listens on port `8080` inside its container.

---

# Git

## Clone the Repository

```bash
git clone https://github.com/Chukwuemeka-Peter-Eze/jenkins-multibranch-pipeline.git
```

## Create a Feature Branch

```bash
git checkout -b feature/example-branch
```

## Stage Changes

```bash
git add .
```

## Commit Changes

```bash
git commit -m "message"
```

## Push a Feature Branch

```bash
git push origin feature/example-branch
```

## Check the Latest Commit Message

This is also used by the pipeline to detect Jenkins-generated version commits.

```bash
git log -1 --pretty=%B
```

The pipeline looks for:

```text
[jenkins-skip]
```

---

# Maven

## Run Tests

Used by the `Test` stage:

```bash
mvn test
```

## Build the Application

Used by the `Build` stage:

```bash
mvn clean package -DskipTests
```

Tests have already been executed in the preceding `Test` stage, so the package command skips them during the build stage.

## Read the Current Application Version

Used by the `Determine Current Version` stage:

```bash
mvn -q help:evaluate \
  -Dexpression=project.version \
  -DforceStdout
```

Example result:

```text
1.1.0
```

## Increment the Application Version

Used by the `Increment Version` stage:

```bash
mvn org.codehaus.mojo:versions-maven-plugin:2.16.2:set \
  -DnewVersion=1.1.1 \
  -DgenerateBackupPoms=false
```

The pipeline calculates the new version automatically before executing this command.

---

# Docker

## Build the Application Image

The image tag uses the application version:

```bash
docker build \
  -t docker.io/pierrechukason/my-demo-app:VERSION \
  .
```

Example:

```bash
docker build \
  -t docker.io/pierrechukason/my-demo-app:1.1.1 \
  .
```

---

## Authenticate with Docker Hub

The pipeline uses Jenkins Credentials and passes the password/token through standard input:

```bash
docker login docker.io \
  -u USERNAME \
  --password-stdin
```

The actual credential values should never be hard-coded into the repository.

---

## Push the Image

```bash
docker push docker.io/pierrechukason/my-demo-app:VERSION
```

Example:

```bash
docker push docker.io/pierrechukason/my-demo-app:1.1.1
```

---

## Pull the Image

Used during deployment:

```bash
docker pull docker.io/pierrechukason/my-demo-app:VERSION
```

Example:

```bash
docker pull docker.io/pierrechukason/my-demo-app:1.1.1
```

---

## Stop the Existing Application Container

```bash
docker stop my-demo-app
```

The Jenkins pipeline uses `|| true` so that deployment can continue even if the container does not already exist.

---

## Remove the Existing Application Container

```bash
docker rm my-demo-app
```

Again, the deployment pipeline tolerates the case where the container does not already exist.

---

## Start the Application Container

The application listens on port `8080` inside the container.

Because Jenkins occupies host port `8080`, the current deployment maps host port `8081` to container port `8080`:

```bash
docker run -d \
  --name my-demo-app \
  -p 8081:8080 \
  docker.io/pierrechukason/my-demo-app:VERSION
```

Example:

```bash
docker run -d \
  --name my-demo-app \
  -p 8081:8080 \
  docker.io/pierrechukason/my-demo-app:1.1.1
```

The resulting network path is:

```text
EC2 host :8081
      ↓
Container :8080
```

---

## Check Running Containers

```bash
docker ps
```

---

## Check All Containers

```bash
docker ps -a
```

---

## View Application Logs

```bash
docker logs my-demo-app
```

For continuously streamed logs:

```bash
docker logs -f my-demo-app
```

---

## Check the Application Locally

From the EC2 host:

```bash
curl http://localhost:8081
```

A successful response confirms that the application container is reachable through the host port.

---

## Check Port Mapping

```bash
docker port my-demo-app
```

Expected mapping:

```text
8080/tcp -> 0.0.0.0:8081
```

---

## Docker Logout

```bash
docker logout docker.io/pierrechukason
```

The pipeline performs Docker logout after registry operations.

---

# SSH

## Generate the Jenkins Deployment Key

The project uses a dedicated ED25519 SSH identity:

```bash
ssh-keygen -t ed25519 -C "jenkins-deployment"
```

A suitable filename is:

```text
~/.ssh/jenkins-deployment
```

This produces:

```text
~/.ssh/jenkins-deployment
~/.ssh/jenkins-deployment.pub
```

---

## Copy the Public Key

If `ssh-copy-id` is available:

```bash
ssh-copy-id \
  -i ~/.ssh/jenkins-deployment.pub \
  ubuntu@DEPLOY_HOST
```

In the current environment, `DEPLOY_HOST` is the EC2 instance that also hosts Jenkins.

---

## Test SSH Manually

```bash
ssh \
  -i ~/.ssh/jenkins-deployment \
  ubuntu@DEPLOY_HOST
```

This should succeed without a password prompt.

Testing this independently is useful when troubleshooting Jenkins SSH deployment.

---

# Linux / EC2 Host

The following commands apply to the current EC2 host that runs Jenkins and the deployed application.

## Install Docker

```bash
curl -fsSL https://get.docker.com | sh
```

---

## Add the Current User to the Docker Group

```bash
sudo usermod -aG docker $USER
```

---

## Refresh Group Membership

```bash
newgrp docker
```

---

## Verify Docker

```bash
docker version
```

---

## Test Docker

```bash
docker run hello-world
```

---

## Check Docker Socket Permissions

Useful when diagnosing Docker permission problems:

```bash
ls -l /var/run/docker.sock
```

Check the socket group ID:

```bash
stat -c '%g' /var/run/docker.sock
```

This is particularly relevant when Jenkins itself is running inside a Docker container and needs access to the host Docker daemon.

---

# Jenkins Docker Troubleshooting

## Verify Docker Access

From the Jenkins environment:

```bash
docker version
```

If Jenkins cannot access Docker, check the Docker socket permissions and the group mapping between the Jenkins container and the host.

---

# Deployment Command Sequence

The `Deploy` stage effectively performs the following operations on the deployment target.

## 1. Docker Login

```bash
docker login docker.io/pierrechukason \
  -u USERNAME \
  --password-stdin
```

## 2. Pull the New Image

```bash
docker pull docker.io/pierrechukason/my-demo-app:VERSION
```

## 3. Stop the Previous Container

```bash
docker stop my-demo-app
```

## 4. Remove the Previous Container

```bash
docker rm my-demo-app
```

## 5. Start the New Container

```bash
docker run -d \
  --name my-demo-app \
  -p 8081:8080 \
  docker.io/pierrechukason/my-demo-app:VERSION
```

## 6. Log Out

```bash
docker logout docker.io/pierrechukason
```

The pipeline executes these operations through Jenkins automation rather than requiring manual intervention.

---

# Versioning Commands

The pipeline's versioning flow can be summarized as:

```text
Read version
    ↓
mvn help:evaluate
    ↓
Increment patch
    ↓
versions-maven-plugin
    ↓
Update pom.xml
    ↓
Build Docker image using NEW_VERSION
    ↓
Push image
    ↓
Commit pom.xml
```

For example:

```text
1.1.0
  ↓
1.1.1
  ↓
docker.io/pierrechukason/my-demo-app:1.1.1
```

---

# Recursive Trigger Detection

The pipeline checks the latest Git commit:

```bash
git log -1 --pretty=%B
```

It looks for:

```text
[jenkins-skip]
```

A Jenkins-generated commit looks like:

```text
[jenkins-skip] bump version to 1.1.1
```

When the marker is detected, the pipeline sets its skip flag and prevents the normal pipeline stages from running again.

This prevents:

```text
Jenkins
  ↓
Git commit
  ↓
GitHub webhook
  ↓
Jenkins
  ↓
Git commit
  ↓
GitHub webhook
  ↓
...
```

from becoming an infinite pipeline loop.

---

# Git Version Commit

The pipeline stages the updated Maven project file:

```bash
git add pom.xml
```

Creates the automated version commit:

```bash
git commit -m "[jenkins-skip] bump version to VERSION"
```

And pushes the branch:

```bash
git push HEAD:BRANCH
```

Authentication is provided through the Jenkins credential:

```text
GitHub-PAT
```

The actual token is never stored in the repository.

---

# Jenkins Pipeline Steps Used

| Step                          | Purpose                                              |
| ----------------------------- | ---------------------------------------------------- |
| `sh`                          | Execute shell commands                               |
| `script { }`                  | Execute Groovy logic inside a Declarative Pipeline   |
| `withCredentials([...])`      | Temporarily inject Jenkins credentials               |
| `sshagent([...])`             | Provide an SSH identity to deployment commands       |
| `when { branch '...' }`       | Restrict a stage to a specific branch                |
| `when { expression { ... } }` | Restrict a stage using a computed condition          |
| `anyOf { ... }`               | Allow a stage when one of several conditions matches |
| `allOf { ... }`               | Require multiple conditions to match                 |
| `disableConcurrentBuilds()`   | Prevent overlapping executions of the pipeline       |
| `buildDiscarder(...)`         | Limit retained Jenkins build history                 |
| `timeout(...)`                | Prevent a pipeline from running indefinitely         |

---

# Branch-to-Command Summary

## Feature Branches

```text
feature/*
   ↓
mvn test
   ↓
mvn clean package -DskipTests
```

No Docker image is built or pushed.

---

## Develop

```text
develop
   ↓
mvn test
   ↓
Read version
   ↓
Increment patch version
   ↓
mvn clean package -DskipTests
   ↓
docker build
   ↓
docker push
   ↓
Commit version change
```

No deployment occurs.

---

## Main

```text
main
   ↓
mvn test
   ↓
Read version
   ↓
Increment patch version
   ↓
mvn clean package -DskipTests
   ↓
docker build
   ↓
docker push
   ↓
SSH deployment
   ↓
docker pull
   ↓
stop/remove old container
   ↓
docker run -p 8081:8080
   ↓
Commit version change
```

This represents the complete CI/CD path implemented in the project.

---

# Useful Validation Commands

## Check the Application

```bash
curl http://localhost:8081
```

## Check Containers

```bash
docker ps
```

## Check Application Logs

```bash
docker logs my-demo-app
```

## Check Docker Images

```bash
docker images
```

## Check Latest Git Commit

```bash
git log -1 --pretty=%B
```

## Check Current Maven Version

```bash
mvn -q help:evaluate \
  -Dexpression=project.version \
  -DforceStdout
```

---

# Engineering Takeaway

These commands represent the individual operations behind the automated pipeline.

The important distinction is that developers normally do not need to execute the complete deployment sequence manually. Jenkins orchestrates these commands according to the branch and pipeline conditions.

The commands remain useful for troubleshooting because they allow individual operations to be tested independently of Jenkins.