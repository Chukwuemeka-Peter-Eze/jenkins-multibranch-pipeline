# Deployment Server Setup

This guide covers preparing the target server that Jenkins deploys to over SSH, separate from the Jenkins server itself.

## Architecture

```text
GitHub
   │ git push
   ▼
Jenkins Server
   │ build + docker build
   │ SSH
   ▼
Deployment Server
   │ docker run
   ▼
Application
```

Jenkins and the deployment server are deliberately two different machines. Jenkins builds and pushes the image; the deployment server just runs it.

## 1. Provision the deployment server

Launch a second Ubuntu EC2 instance (separate from the Jenkins server), named something like `jenkins-app-server`. A small instance size is sufficient for a portfolio project.

## 2. Configure its Security Group

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | My IP |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 |

Port 8080 is open broadly here because this is a learning/portfolio deployment. A production setup would put the application behind a reverse proxy or load balancer instead of exposing the app port directly.

## 3. Confirm manual SSH access works first

Before touching Jenkins, verify you can reach the server directly:

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_SERVER_PUBLIC_IP
```

If this fails, fix it before going any further, Jenkins can't succeed at something your own terminal can't do.

## 4. Install Docker on the deployment server

While connected to the server:

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

If the hello-world message appears, the server is ready to receive containers.

## 5. Generate a dedicated SSH key for Jenkins

Rather than reusing your personal `.pem`, give Jenkins its own identity. From the Jenkins server:

```bash
ssh-keygen -t ed25519 -C "jenkins-deployment"
# save to: /home/ubuntu/.ssh/jenkins_deploy
# leave the passphrase empty for automation
```

This produces a private key (`jenkins_deploy`) and a public key (`jenkins_deploy.pub`).

## 6. Authorize that key on the deployment server

From the Jenkins server:

```bash
ssh-copy-id -i ~/.ssh/jenkins_deploy.pub ubuntu@YOUR_APP_SERVER_IP
```

Or manually, on the deployment server:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys   # paste the full public key on one line
chmod 600 ~/.ssh/authorized_keys
```

## 7. Confirm the dedicated key works, without a password prompt

From the Jenkins server:

```bash
ssh -i ~/.ssh/jenkins_deploy ubuntu@YOUR_APP_SERVER_IP
```

This must succeed cleanly before you configure the Jenkins credential. If it prompts for a password, the public key isn't authorized correctly yet, go back to step 6.

## 8. Add the private key to Jenkins

See `docs/credentials.md` for the exact steps to store this key in Jenkins and wire it into the pipeline.

## Result

Once this is done, the pipeline's `Deploy` stage can SSH into this server, pull the newly built image, stop whatever's currently running, and start the new container, all without any manual intervention.