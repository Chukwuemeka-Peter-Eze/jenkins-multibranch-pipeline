# Jenkins Multibranch Pipeline: Commands Reference

Commands used for repository management, Jenkins administration, application versioning, Docker image operations, and Git automation.

---

## Table of Contents

* [Git](#git)
* [Jenkins Container](#jenkins-container)
* [Docker](#docker)
* [Maven](#maven)
* [Version Inspection](#version-inspection)
* [Git Version Commit](#git-version-commit)
* [Validation](#validation)
* [Security Note](#security-note)

---

## Git

```bash
git clone https://github.com/Chukwuemeka-Peter-Eze/jenkins-multibranch-pipeline.git
cd jenkins-multibranch-pipeline

git status                          # Check status
git branch -a                       # List branches
git checkout -b feature/<branch-name>  # Create a branch
git checkout <branch-name>          # Switch branches
git pull origin <branch-name>       # Pull changes
git add .                           # Stage changes
git commit -m "feat: update application version"   # Commit
git push origin <branch-name>       # Push
```

---

## Jenkins Container

```bash
docker ps                                    # List Jenkins containers
docker inspect <jenkins-container>           # Inspect Jenkins
docker exec -it <jenkins-container> bash     # Open a shell
docker exec -u 0 -it <jenkins-container> bash  # Open a root shell
```

---

## Docker

```bash
docker images                             # List images
docker build -t <image-name>:<version> .  # Build an image
docker ps                                 # List running containers
docker inspect <image-name>:<version>     # Inspect an image
```

---

## Maven

```bash
mvn -version         # Display Maven version
mvn clean package    # Build the application
mvn test             # Run tests
mvn help:evaluate -Dexpression=project.version -q -DforceStdout   # Inspect the project version
```

> Verify the exact command against the application implementation before using it in final documentation.

---

## Version Inspection

```bash
git status                                  # Current working tree
git log --oneline -10                       # Recent commits
git diff                                     # Inspect changes
mvn help:evaluate -Dexpression=project.version -q -DforceStdout   # Application version
```

---

## Git Version Commit

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

## Validation

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

Never place passwords, access tokens, private keys, or webhook secrets inside this file. Use placeholders for sensitive values.