# Jenkins Credentials Setup

This pipeline requires three credentials stored in Jenkins.

The Jenkinsfile contains only the **credential IDs**. The actual secrets remain in Jenkins' credential store and are injected into the pipeline only when required.

The three credentials are:

```text
Docker-Hub-Credentials
deploy-ssh-credentials
GitHub-PAT
```

---

# Where Credentials Are Stored

In Jenkins, navigate to:

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

The exact navigation can vary slightly depending on the Jenkins version and installed plugins.

---

# 1. Docker Hub Credential

This credential is used to authenticate with Docker Hub so Jenkins can push the Docker image.

The pipeline also uses the same credential when the deployment target logs in to Docker Hub to pull the image.

### Configuration

| Field    | Value                               |
| -------- | ----------------------------------- |
| Kind     | Username with password              |
| Username | Your Docker Hub username            |
| Password | Docker Hub password or access token |
| ID       | `Docker-Hub-Credentials`            |

The ID must match the Jenkinsfile:

```groovy
DOCKER_CREDENTIALS_ID = 'Docker-Hub-Credentials'
```

The pipeline uses the credential through:

```groovy
withCredentials([usernamePassword(
    credentialsId: DOCKER_CREDENTIALS_ID,
    usernameVariable: 'REG_USER',
    passwordVariable: 'REG_PASS'
)])
```

Docker authentication is performed using:

```bash
docker login ... --password-stdin
```

This prevents the password from being written directly into the Jenkinsfile.

---

# 2. SSH Deployment Credential

This credential is used by the `Deploy` stage to establish an SSH connection to the deployment target.

In the current learning environment, the deployment target is the **same EC2 instance running Jenkins**.

The SSH connection is nevertheless useful because it demonstrates the same deployment mechanism that can later be used with a separate application server.

### Configuration

| Field       | Value                                    |
| ----------- | ---------------------------------------- |
| Kind        | SSH Username with private key            |
| Username    | `ubuntu`                                 |
| Private Key | Paste the Jenkins deployment private key |
| ID          | `deploy-ssh-credentials`                 |

The private key should include the complete key contents, including its `BEGIN` and `END` lines.

The credential ID must match:

```groovy
DEPLOY_SSH_CREDENTIALS_ID = 'deploy-ssh-credentials'
```

The Jenkinsfile loads the credential using:

```groovy
sshagent(credentials: [DEPLOY_SSH_CREDENTIALS_ID]) {
    // deployment commands
}
```

---

# 3. GitHub Personal Access Token

This credential is used by the `Commit Version Change` stage to push the automatically updated `pom.xml` back to GitHub.

### Recommended Credential

| Field    | Value                        |
| -------- | ---------------------------- |
| Kind     | Username with password       |
| Username | Your GitHub username         |
| Password | GitHub Personal Access Token |
| ID       | `GitHub-PAT`                 |

The ID must match:

```groovy
GIT_CREDENTIALS_ID = 'GitHub-PAT'
```

The token should have only the permissions required for the repository operation.

For a classic GitHub Personal Access Token, repository write access is required for the version-commit operation.

For fine-grained tokens, grant access only to the required repository and required contents permissions.

Treat the token like a password.

---

# How GitHub Authentication Is Used

The version-commit stage retrieves the credential through Jenkins:

```groovy
withCredentials([usernamePassword(
    credentialsId: GIT_CREDENTIALS_ID,
    usernameVariable: 'GIT_USER',
    passwordVariable: 'GIT_TOKEN'
)]) {
    // git commit and push
}
```

The token is then used for the Git push operation.

The token itself should never be committed to GitHub or placed directly in the Jenkinsfile.

---

# Credential ID Verification

Credential IDs are case-sensitive identifiers.

For example, if the Jenkinsfile contains:

```groovy
DOCKER_CREDENTIALS_ID = 'Docker-Hub-Credentials'
```

the Jenkins credential must use exactly:

```text
Docker-Hub-Credentials
```

and not:

```text
docker-hub-credentials
```

or:

```text
DockerHubCredentials
```

A mismatch can result in errors such as:

```text
credentials not found
```

---

# Credential Security Rules

Never place the following directly in the repository:

```text
Passwords
Private SSH keys
GitHub tokens
Docker Hub tokens
AWS secret keys
```

Instead:

```text
Jenkinsfile
    ↓
Credential ID
    ↓
Jenkins Credential Store
    ↓
Temporary credential injection
    ↓
Pipeline operation
```

This keeps sensitive values separate from the source code.

---

# Verify Credentials Before Running the Full Pipeline

When troubleshooting, validate credentials independently where practical.

### Docker

Confirm that the Docker Hub credential is valid and has permission to push to the configured repository.

### SSH

Confirm that the dedicated deployment key can connect to the target:

```bash
ssh -i ~/.ssh/jenkins-deployment ubuntu@YOUR_EC2_PUBLIC_IP
```

### GitHub

Confirm that the GitHub token has permission to push to the repository.

Testing each authentication mechanism separately makes it easier to determine whether a failure originates from Jenkins or from the underlying service.

---

# Current Credential Architecture

The complete pipeline uses:

```text
                    Jenkins Credential Store
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
 Docker-Hub-Credentials  deploy-ssh-credentials  GitHub-PAT
             │                │                │
             ▼                ▼                ▼
        Docker Hub          SSH Deploy         GitHub
```

The Jenkinsfile references only the credential IDs.

This separation is especially important in a Multibranch Pipeline because multiple branches can execute the same pipeline logic while sensitive authentication material remains outside the repository.

---

# Engineering Takeaway

Credentials are infrastructure configuration, not application source code.

A good CI/CD pipeline should make it possible to publish and deploy software without requiring developers to place passwords, tokens, or private keys inside the repository.

This project therefore keeps authentication material in Jenkins and keeps the Jenkinsfile responsible only for describing **which credential is required and when it should be used**.