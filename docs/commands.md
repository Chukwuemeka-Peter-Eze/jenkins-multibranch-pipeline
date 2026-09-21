# Commands Reference

A reference of the commands this project's pipeline runs, and the manual commands used while building and testing it. Grouped by tool.

---

## Git

```bash
git clone https://github.com/Chukwuemeka-Peter-Eze/jenkins-multibranch-pipeline.git
git checkout -b feature/example-branch
git add .
git commit -m "message"
git push origin feature/example-branch
git log -1 --pretty=%B          # used by the pipeline to check the last commit message
```

## Maven

```bash
mvn test                                                  # Test stage
mvn clean package -DskipTests                             # Build stage
mvn -q help:evaluate -Dexpression=project.version -DforceStdout   # Determine Current Version stage
mvn org.codehaus.mojo:versions-maven-plugin:2.16.2:set -DnewVersion=X.Y.Z -DgenerateBackupPoms=false   # Increment Version stage
```

## Docker

```bash
docker build -t docker.io/pierrechukason/my-demo-app:VERSION .
docker login docker.io -u USERNAME --password-stdin
docker push docker.io/pierrechukason/my-demo-app:VERSION
docker pull docker.io/pierrechukason/my-demo-app:VERSION
docker stop my-demo-app
docker rm my-demo-app
docker run -d --name my-demo-app -p 8080:8080 docker.io/pierrechukason/my-demo-app:VERSION
docker ps
docker logs my-demo-app
```

## SSH

```bash
ssh-keygen -t ed25519 -C "jenkins-deployment"
ssh-copy-id -i ~/.ssh/jenkins_deploy.pub ubuntu@DEPLOY_HOST
ssh -i ~/.ssh/jenkins_deploy ubuntu@DEPLOY_HOST
```

## Linux (deployment server)

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

## Jenkins Pipeline Steps Used

| Step | Purpose |
|---|---|
| `sh` | Run shell commands inside a stage |
| `script { }` | Run Groovy logic inline within Declarative Pipeline |
| `withCredentials([...])` | Inject a Jenkins credential into a stage without exposing it |
| `sshagent([...])` | Wrap SSH commands with a Jenkins-managed private key |
| `when { branch '...' }` | Restrict a stage to a specific branch |
| `when { expression { ... } }` | Restrict a stage based on a computed condition (used for recursive-trigger skipping) |