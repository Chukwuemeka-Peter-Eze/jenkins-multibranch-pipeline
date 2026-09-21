# Deployment Target Setup

This guide covers preparing the environment that Jenkins deploys the Dockerized application to over SSH.

In the current learning environment, **Jenkins and the application deployment target run on the same AWS EC2 instance**. This keeps the project infrastructure simple while still demonstrating SSH-based deployment, Docker image publishing, and automated application replacement.

A future production-oriented version of the project can move the application to a separate EC2 instance, Amazon EKS, or another dedicated runtime environment.

---

## Architecture

### Current Learning Architecture

```text
GitHub
   │
   │ git push
   ▼
GitHub Webhook
   │
   ▼
Jenkins Multibranch Pipeline
   │
   │ build + Docker build + push
   ▼
AWS EC2 Instance
   │
   ├── Jenkins container
   │     └── host port 8080
   │
   └── Application container
         ├── host port 8081
         └── container port 8080
```

The deployment stage still uses SSH:

```text
Jenkins
   │
   │ SSH
   ▼
Same EC2 deployment target
   │
   ├── docker pull
   ├── docker stop
   ├── docker rm
   └── docker run
```

Jenkins occupies host port `8080`, so the application is exposed on host port `8081` while continuing to listen on port `8080` inside the container.

---

# 1. Provision the AWS EC2 Instance

For the current learning setup, provision an Ubuntu EC2 instance that will host Jenkins and the deployed application.

The instance should have enough resources to run:

* Jenkins
* Docker
* Maven builds
* The application container

A small instance can be sufficient for a portfolio project, although the required resources depend on the workload.

If Jenkins is already running on an existing EC2 instance, the same instance can be used as the deployment target.

---

# 2. Configure the Security Group

The current environment needs network access for Jenkins and, if the application is being tested externally, the application port.

A typical learning setup is:

| Type        | Protocol | Port | Source                    |
| ----------- | -------- | ---: | ------------------------- |
| SSH         | TCP      |   22 | My IP / trusted source    |
| Jenkins     | TCP      | 8080 | Your IP or trusted source |
| Application | TCP      | 8081 | Required testing source   |

Port `8081` is used because Jenkins already occupies host port `8080`.

For production environments:

* Restrict SSH access.
* Avoid exposing Jenkins broadly to the internet.
* Avoid exposing application ports directly where possible.
* Prefer a reverse proxy or load balancer.
* Use HTTPS for externally accessible applications.

---

# 3. Confirm Manual SSH Access

Before configuring Jenkins, verify that SSH access to the EC2 instance works from your terminal.

```bash
chmod 400 your-key.pem

ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

If this fails, fix the SSH or AWS networking problem before troubleshooting Jenkins.

The principle is simple:

> Jenkins cannot successfully SSH to a host that cannot be reached manually.

---

# 4. Install Docker

If Docker is not already installed on the EC2 instance:

```bash
curl -fsSL https://get.docker.com | sh

sudo usermod -aG docker $USER

newgrp docker
```

Verify Docker:

```bash
docker version
```

Then test the installation:

```bash
docker run hello-world
```

If the `hello-world` container runs successfully, Docker is ready to run the application.

---

# 5. Generate a Dedicated Jenkins SSH Key

Jenkins should use a dedicated deployment identity rather than your personal EC2 private key.

On the Jenkins environment, generate an ED25519 key:

```bash
ssh-keygen -t ed25519 -C "jenkins-deployment"
```

Use a dedicated filename such as:

```text
~/.ssh/jenkins-deployment
```

This creates:

```text
jenkins-deployment
jenkins-deployment.pub
```

The private key should remain secret.

---

# 6. Authorize the Jenkins Public Key

Add the public key to the `authorized_keys` file for the EC2 `ubuntu` user.

For example:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Then add the public key:

```bash
nano ~/.ssh/authorized_keys
```

Paste the complete public key on one line.

Set the correct permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

Alternatively, if appropriate:

```bash
ssh-copy-id -i ~/.ssh/jenkins-deployment.pub ubuntu@YOUR_EC2_PUBLIC_IP
```

---

# 7. Verify the Dedicated Jenkins Key

Before adding the key to Jenkins, verify that it works manually:

```bash
ssh -i ~/.ssh/jenkins-deployment ubuntu@YOUR_EC2_PUBLIC_IP
```

The connection should succeed without requiring a password.

If it fails, troubleshoot the SSH configuration before continuing.

This separates SSH infrastructure problems from Jenkins configuration problems.

---

# 8. Add the SSH Private Key to Jenkins

Store the private key in Jenkins Credentials.

The credential used by this project is:

```text
deploy-ssh-credentials
```

See:

```text
docs/credentials.md
```

for the complete Jenkins credential configuration.

---

# 9. Verify the Application Port

The application listens on port `8080` inside the Docker container.

However, Jenkins already uses host port `8080`.

Therefore the deployment command uses:

```bash
docker run -d \
  --name my-demo-app \
  -p 8081:8080 \
  IMAGE
```

The mapping is:

```text
EC2 host :8081
       ↓
Container :8080
```

Verify the application locally on the EC2 host:

```bash
curl http://localhost:8081
```

A successful response confirms that the deployed application is reachable through the host port.

---

# 10. Verify the Deployment Container

Check running containers:

```bash
docker ps
```

The application should appear as:

```text
my-demo-app
```

Check its logs if necessary:

```bash
docker logs my-demo-app
```

Check the port mapping:

```bash
docker port my-demo-app
```

---

# 11. Result

Once the environment is prepared, the Jenkins `Deploy` stage can:

```text
SSH to deployment target
        ↓
Docker login
        ↓
Pull the newly published image
        ↓
Stop the previous application container
        ↓
Remove the previous container
        ↓
Start the new application container
        ↓
Docker logout
```

No manual container replacement is required after a successful `main` pipeline execution.

---

# Future Architecture: Separate Deployment Host

The current same-host architecture is intentionally simple for this learning project.

A future implementation can separate Jenkins from application runtime:

```text
GitHub
   │
   ▼
Jenkins EC2
   │
   │ SSH
   ▼
Application EC2
   │
   ▼
Application Container
```

This would provide stronger separation between CI infrastructure and application runtime.

Another future evolution is:

```text
GitHub
   ↓
Jenkins
   ↓
Docker Registry
   ↓
Amazon EKS
   ↓
Kubernetes Deployment
```

The current project therefore provides a foundation for moving from a simple Docker deployment toward a more production-oriented Kubernetes architecture.