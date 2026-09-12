# Application Versioning

## Table of Contents

* [Purpose](#purpose)
* [Versioning Flow](#versioning-flow)
* [Local Version Increment](#local-version-increment)
* [Pipeline Version Increment](#pipeline-version-increment)
* [Docker Alignment](#docker-alignment)
* [Evidence](#evidence)

---

## Purpose

Application versioning establishes an explicit identity for application releases and associated artifacts.

---

## Versioning Flow

```text
Current Version
      ↓
Version Increment
      ↓
Build
      ↓
Docker Image
      ↓
Git Commit
```

---

## Local Version Increment

The initial versioning exercise includes incrementing the application version using the build tooling.

---

## Pipeline Version Increment

The pipeline can automate version changes as part of CI/CD execution. The project checklist specifically identifies both local Maven version incrementing and version incrementing within the Jenkins Pipeline itself.

---

## Docker Alignment

The Dockerfile should be adjusted where necessary so the resulting container artifact corresponds appropriately with the application version.

---

## Evidence

![Version Before](../media/screenshots/version-before.png)

![Version After](../media/screenshots/version-after.png)

![Versioned Docker Image](../media/screenshots/versioned-image.png)