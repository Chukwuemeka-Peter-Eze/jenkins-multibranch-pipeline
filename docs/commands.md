# Jenkins Multibranch Pipeline - Commands Reference

> Commands used for repository management, Jenkins administration, application versioning, Docker image operations, and Git automation.

---

## Table of Contents

* [Git](#git)
* [Jenkins Container](#jenkins-container)
* [Docker](#docker)
* [Maven](#maven)
* [Version Inspection](#version-inspection)
* [Git Version Commit](#git-version-commit)
* [Validation](#validation)

---

# Git

Clone the repository:

```bash
git clone https://github.com/Chukwuemeka-Peter-Eze/Jenkins-multibranch-pipeline.git
```

Enter the repository:

```bash
cd Jenkins-multibranch-pipeline
```

Check status:

```bash
git status
```

List branches:

```bash
git branch -a
```

Create a branch:

```bash
git checkout -b feature/<branch-name>
```

Switch branches:

```bash
git checkout <branch-name>
```

Pull changes:

```bash
git pull origin <branch-name>
```

Stage changes:

```bash
git add .
```

Commit:

```bash
git commit -m "feat: update application version"
```

Push:

```bash
git push origin <branch-name>
```

---

# Jenkins Container

List Jenkins containers:

```bash
docker ps
```

Inspect Jenkins:

```bash
docker inspect <jenkins-container>
```

Open a shell:

```bash
docker exec -it <jenkins-container> bash
```

Open a root shell:

```bash
docker exec -u 0 -it <jenkins-container> bash
```

---

# Docker

List images:

```bash
docker images
```

Build an image:

```bash
docker build -t <image-name>:<version> .
```

List running containers:

```bash
docker ps
```

Inspect an image:

```bash
docker inspect <image-name>:<version>
```

---

# Maven

Display Maven version:

```bash
mvn -version
```

Build the application:

```bash
mvn clean package
```

Run tests:

```bash
mvn test
```

Inspect the project version:

```bash
mvn help:evaluate -Dexpression=project.version -q -DforceStdout
```

> Verify the exact command against the application implementation before using it in final documentation.

---

# Version Inspection

Check the current Git working tree:

```bash
git status
```

Inspect recent commits:

```bash
git log --oneline -10
```

Inspect changes:

```bash
git diff
```

Check the application version:

```bash
mvn help:evaluate -Dexpression=project.version -q -DforceStdout
```

---

# Git Version Commit

Conceptual workflow:

```text
Update version
      ↓
Validate changes
      ↓
git status
      ↓
git add
      ↓
git commit
      ↓
git push
```

Example placeholder:

```bash
git add <version-file>
git commit -m "chore: update application version"
git push origin <branch-name>
```

The final command sequence must reflect the implementation actually used.

---

# Validation

Verify:

```text
Branch
  ↓
Jenkinsfile
  ↓
Pipeline
  ↓
Version
  ↓
Docker image
  ↓
Git commit
  ↓
Trigger filtering
```

---

## Security Note

Never place:

* passwords
* access tokens
* private keys
* webhook secrets

inside this file.

Use placeholders for sensitive values.
