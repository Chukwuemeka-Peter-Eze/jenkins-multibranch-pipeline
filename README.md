# Jenkins Multibranch Pipeline

> Branch-aware CI/CD workflows using Jenkins Multibranch Pipelines, secure credentials, Git webhooks, and automated application version management.

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins&logoColor=white)](#)
[![Pipeline](https://img.shields.io/badge/Jenkins-Pipeline-blue?logo=jenkins&logoColor=white)](#)
[![Git](https://img.shields.io/badge/Git-Version%20Control-orange?logo=git&logoColor=white)](#)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Automation-green)](#)
[![License](https://img.shields.io/badge/License-MIT-green)](#)

---

## Project Status

| Capability | Status |
|---|---|
| Multibranch Pipeline job (branch discovery) | Implemented |
| Branch-specific pipeline logic (`main` / `develop` / `feature/*`) | Implemented |
| Jenkins Credentials integration | Implemented |
| Git webhook trigger | Implemented |
| Application version incrementing | Implemented |
| Docker image build and version tagging | Implemented |
| Automated version commit back to Git | Implemented |
| Recursive-trigger prevention | Implemented |

The `Jenkinsfile` in this repo reflects the full implementation described below. Screenshots throughout this document show the pipeline running end to end.

---

## Table of Contents

* [Project Status](#project-status)
* [Overview](#overview)
* [Engineering Problem](#engineering-problem)
* [Solution](#solution)
* [Project Objectives](#project-objectives)
* [Engineering Highlights](#engineering-highlights)
* [Architecture](#architecture)
* [CI/CD Workflow](#cicd-workflow)
* [Multibranch Pipeline](#multibranch-pipeline)
* [Branch-Based Pipeline Logic](#branch-based-pipeline-logic)
* [Credentials Management](#credentials-management)
* [Webhook Automation](#webhook-automation)
* [Application Versioning](#application-versioning)
* [Versioning Workflow](#versioning-workflow)
* [Docker Image Versioning](#docker-image-versioning)
* [Version Commit Workflow](#version-commit-workflow)
* [Preventing Recursive Pipeline Execution](#preventing-recursive-pipeline-execution)
* [Deployment](#deployment)
* [Technology Stack](#technology-stack)
* [Repository Structure](#repository-structure)
* [Setup & Configuration](#setup--configuration)
* [Security Considerations](#security-considerations)
* [Troubleshooting](#troubleshooting)
* [Engineering Decisions](#engineering-decisions)
* [Lessons Learned](#lessons-learned)
* [Future Improvements](#future-improvements)
* [Related Projects](#related-projects)
* [Connect](#connect)
* [License](#license)

---

## Overview

Modern application repositories commonly contain multiple branches representing different stages of development and delivery. A CI/CD system needs to discover these branches, execute the appropriate pipeline logic, respond to repository changes, securely access required resources, and manage application versions consistently.

This project implements a Jenkins-based approach using Multibranch Pipelines, branch-aware Jenkinsfile logic, Jenkins Credentials, Git webhooks, automated application versioning, Docker image version alignment, automated commits from Jenkins, and protection against recursive pipeline execution.

The result is a branch-aware CI/CD workflow that connects source-control activity with automated build and delivery processes.

![Pipeline Overview](./media/screenshots/pipeline-overview.png)
*Full pipeline run, all stages, showing test through deploy completing successfully.*

---

## Engineering Problem

A single static Jenkins pipeline becomes increasingly difficult to manage when a repository contains multiple active branches. Different branches require different behavior:

```text
feature/*
    ↓
Development validation

develop
    ↓
Integration workflow

main
    ↓
Production-oriented workflow
```

At the same time, the pipeline needs secure credentials to interact with external services and an automated mechanism for triggering builds when changes reach the repository.

Application versioning introduces another consideration. If the pipeline changes the application version and commits that change back to Git, the resulting commit can itself become a source-control event that triggers another pipeline execution.

> **The engineering challenge:** how can Jenkins automatically discover and build multiple branches, securely access required resources, respond to repository changes, manage application versions, and avoid unintended recursive execution?

---

## Solution

```text
Git Repository
      │
      │ branch activity
      ▼
Git Webhook
      │
      ▼
Jenkins Multibranch Pipeline
      │
      ├── Discover branches
      │
      ├── Load branch Jenkinsfile
      │
      ├── Retrieve credentials
      │
      ├── Execute branch-specific logic
      │
      ├── Build application
      │
      ├── Update application version
      │
      ├── Build Docker image
      │
      └── Commit version change
               │
               ▼
          Git Repository
               │
               ▼
       Trigger protection
```

---

## Project Objectives

* Create a Jenkins Multibranch Pipeline.
* Implement Git-based branch discovery.
* Implement branch-specific pipeline logic.
* Configure secure Jenkins credentials.
* Trigger Jenkins execution through repository webhooks.
* Increment application versions, including from within the pipeline itself.
* Adjust the Dockerfile to support application versions.
* Run the complete pipeline end to end.
* Commit version changes from Jenkins back to Git.
* Prevent Jenkins-generated commits from recursively triggering the pipeline.

---

## Engineering Highlights

* Branch-aware CI/CD design.
* Pipeline-as-code.
* Automated source-control integration.
* Secure credential handling.
* Event-driven pipeline triggering.
* Automated semantic application-version management.
* Version-aware container image creation.
* Controlled write-back from CI to source control.
* Recursive-trigger prevention.
* Clear separation between source-control events and pipeline responsibilities.

---

## Architecture

```text
                         ┌─────────────────────┐
                         │    Git Repository   │
                         │                     │
                         │ main                │
                         │ develop             │
                         │ feature/*           │
                         └──────────┬──────────┘
                                    │
                                    │ Webhook
                                    ▼
                         ┌─────────────────────┐
                         │      Jenkins        │
                         │                     │
                         │ Multibranch Job     │
                         └──────────┬──────────┘
                                    │
                      ┌─────────────┼─────────────┐
                      │             │             │
                      ▼             ▼             ▼
                  main         develop       feature/*
                      │             │             │
                      └─────────────┼─────────────┘
                                    │
                                    ▼
                              Jenkinsfile
                                    │
                         ┌──────────┼──────────┐
                         │          │          │
                         ▼          ▼          ▼
                     Build       Test     Version
                                               │
                                               ▼
                                         Docker Image
                                               │
                                               ▼
                                          Git Commit
                                               │
                                               ▼
                                     Trigger Protection
```

---

## CI/CD Workflow

```text
Developer pushes change
        ↓
Git repository receives change
        ↓
Webhook notifies Jenkins
        ↓
Jenkins identifies affected branch
        ↓
Multibranch Pipeline selects branch
        ↓
Branch Jenkinsfile is loaded
        ↓
Credentials are retrieved securely
        ↓
Application is built and tested
        ↓
Application version is updated
        ↓
Docker image is built
        ↓
Version change is committed
        ↓
Jenkins prevents its own commit
from causing an unintended recursive build
```

---

## Multibranch Pipeline

A Multibranch Pipeline lets Jenkins discover branches containing pipeline definitions and create corresponding pipeline jobs automatically, rather than manually creating an individual Jenkins job for every branch.

### Concept

```text
Repository
│
├── main
│   └── Jenkinsfile
│
├── develop
│   └── Jenkinsfile
│
├── feature/login
│   └── Jenkinsfile
│
└── feature/payment
    └── Jenkinsfile
```

Jenkins discovers the branches and evaluates the pipeline definition associated with each one.

![Multibranch Pipeline](./media/screenshots/multibranch-pipeline.png)
*Jenkins job view showing branches automatically discovered from the repository.*

---

## Branch-Based Pipeline Logic

The pipeline inspects the current branch and applies branch-specific behavior.

```text
if main
    → production-oriented workflow, deploys

if develop
    → integration workflow, builds and publishes, no deploy

if feature/*
    → validation workflow, test and build only
```

![Branch-Based Pipeline Logic](./media/screenshots/branch-based-logic.png)
*Stage view comparing a feature branch run (test and build only) against a main branch run (full pipeline including deploy).*

---

## Credentials Management

CI/CD pipelines frequently require authentication to external systems: source-control repositories, container registries, artifact repositories, cloud platforms, and deployment targets.

Credentials are never hard-coded into the Jenkinsfile. Instead, Jenkins Credentials provide controlled access to sensitive values.

```text
Jenkinsfile
     │
     │ references credential
     ▼
Jenkins Credentials Store
     │
     ▼
Authenticated operation
```

![Jenkins Credentials](./media/screenshots/jenkins-credentials.png)
*Jenkins credentials store showing the configured credential IDs (Docker Hub, deploy SSH key, GitHub PAT), values hidden.*

---

## Webhook Automation

Manual pipeline execution doesn't provide a fully event-driven CI/CD workflow. A webhook lets the source-control system notify Jenkins when relevant repository activity occurs.

```text
Git Push
   │
   ▼
Webhook Event
   │
   ▼
Jenkins
   │
   ▼
Multibranch Pipeline
   │
   ▼
Build
```

![Webhook Configuration](./media/screenshots/webhook-configuration.png)
*GitHub repository webhook configuration, pointed at the Jenkins endpoint.*

**Security considerations:** authentication, secret tokens where supported, source validation, network exposure, Jenkins security configuration, and logging and monitoring all matter here, a webhook endpoint is an entry point into the CI system.

---

## Application Versioning

Application versioning provides a traceable relationship between source code, application version, container image, and deployment artifact:

```text
Source Code
    ↓
Application Version
    ↓
Container Image
    ↓
Deployment Artifact
```

This project increments the application version both locally and within the Jenkins Pipeline itself.

---

## Versioning Workflow

```text
Current Version
      │
      ▼
Version Increment
      │
      ▼
Updated Application Version
      │
      ├───────────────┐
      ▼               ▼
Application       Docker Image
Version           Version
      │               │
      └───────┬───────┘
              ▼
         Git Commit
```

![Application Versioning](./media/screenshots/application-versioning.png)
*Console output showing the version read from pom.xml, incremented, and applied.*

---

## Docker Image Versioning

The application version is reflected directly in the container image strategy:

```text
Application Version
        │
        ▼
Docker Image Tag
```

The Dockerfile and pipeline configuration are aligned with the versioning strategy so the image tag always matches the application version that produced it.

![Docker Image Versioning](./media/screenshots/docker-image-versioning.png)
*Docker Hub repository showing pushed image tags matching each incremented application version.*

---

## Version Commit Workflow

```text
Pipeline starts
     ↓
Determine next version
     ↓
Update application version
     ↓
Update Docker-related version reference
     ↓
Build / validate
     ↓
Commit version change
     ↓
Push to Git
```

![Jenkins Git Commit](./media/screenshots/jenkins-git-commit.png)
*Git commit history showing an automated version-bump commit pushed by Jenkins.*

---

## Preventing Recursive Pipeline Execution

Automated Git commits introduce a potential feedback loop:

```text
Pipeline
   ↓
Updates version
   ↓
Commits to Git
   ↓
Git generates push event
   ↓
Webhook
   ↓
Pipeline starts again
   ↓
Version changes again
   ↓
...
```

This is intentionally controlled so it doesn't happen.

**Actual behavior:**

```text
Developer Commit
      ↓
Webhook
      ↓
Pipeline
      ↓
Jenkins Version Commit
      ↓
Webhook
      ↓
Commit identified as Jenkins-generated
      ↓
Pipeline execution skipped
```

![Recursive Trigger Prevention](./media/screenshots/recursive-trigger-prevention.png)
*Console output of a build triggered by Jenkins' own version-commit, showing it being detected and skipped.*

This is a core part of the project's engineering design, not just a configuration detail.

---

## Deployment

On the `main` branch, the pipeline connects to a dedicated deployment server over SSH, pulls the newly published Docker image, stops the previous container, and starts the new one.

![Deploy Stage](./media/screenshots/deploy-stage-success.png)
*Deploy stage succeeding in the Jenkins pipeline view.*

![Application Running](./media/screenshots/application-live.png)
*The deployed application responding at the deployment server's address.*

---

## Technology Stack

| Technology                   | Purpose                                  |
| ----------------------------- | ------------------------------------------ |
| AWS EC2 | Jenkins server and deployment server infrastructure |
| Ubuntu Linux | Operating system |
| Git | Version control |
| GitHub | Source control repository and webhook source |
| Jenkins | CI/CD orchestration |
| Jenkins Pipeline | Pipeline-as-code |
| Jenkins Multibranch Pipeline | Branch-aware automation |
| Groovy | Jenkins pipeline implementation |
| Java 17 | Application development |
| Apache Maven | Build automation and version management |
| Docker | Containerization |
| Docker Hub | Container registry |
| SSH | Secure remote deployment |

---

## Repository Structure

```text
jenkins-multibranch-pipeline/
│
├── README.md
├── LICENSE
│
├── Jenkinsfile
├── Dockerfile
├── pom.xml
│
├── docs/
│   ├── setup.md
│   ├── credentials.md
│   ├── commands.md
│   ├── troubleshooting.md
│   ├── versioning.md
│   ├── webhooks.md
│   └── lessons-learned.md
│
└── media/
    └── screenshots/
```

---

## Setup & Configuration

This pipeline deploys to a separate server over SSH and uses three Jenkins credentials (Docker Hub, deploy-server SSH key, GitHub PAT).

* **[docs/setup.md](docs/setup.md)** documents provisioning the deployment server, installing Docker, and generating and authorizing a dedicated Jenkins SSH key.
* **[docs/credentials.md](docs/credentials.md)** documents adding the Docker Hub, SSH, and GitHub PAT credentials to Jenkins, and matching their IDs to the Jenkinsfile.
* **[docs/commands.md](docs/commands.md)** is a reference of every command the pipeline runs and the manual commands used while building it.
* **[docs/troubleshooting.md](docs/troubleshooting.md)** covers common failure modes by stage, with likely causes and how to check them.
* **[docs/versioning.md](docs/versioning.md)** explains the versioning approach in depth: why patch-only automation, why not SNAPSHOT, and how the Docker tag stays aligned with the application version.
* **[docs/webhooks.md](docs/webhooks.md)** covers why a webhook was chosen over polling, how it's wired up, and the security considerations around exposing a webhook endpoint.
* **[docs/lessons-learned.md](docs/lessons-learned.md)** reflects on the engineering decisions behind the recursive-trigger protection, credential handling, and the build/deploy server separation.

Every environment-specific value lives in the `environment {}` block at the top of the Jenkinsfile, nothing is hard-coded elsewhere in the pipeline.

---

## Security Considerations

* Never commit secrets.
* Never place passwords directly inside Jenkinsfiles.
* Use Jenkins Credentials.
* Limit credential permissions.
* Avoid printing secrets to logs.
* Protect webhook endpoints.
* Restrict Jenkins administrative access.
* Carefully control Jenkins write access to repositories.
* Review automated Git commits.
* Use dedicated credentials where appropriate.
* Follow least-privilege principles.

---

## Troubleshooting

Real-world challenges encountered during implementation, documented as they came up.

**Branch not discovered.** Check repository configuration, branch discovery strategy, repository permissions, Jenkins credentials, and Jenkins indexing logs.

**Webhook does not trigger Jenkins.** Check webhook configuration, target URL, Jenkins accessibility, event type, authentication and secret configuration, and Jenkins logs.

**Credential authentication fails.** Check the credential ID, credential type, permissions, repository access, and credential scope.

**Version is not updated.** Check the build configuration, Maven configuration, version expression, pipeline stage ordering, and Git working tree.

**Jenkins commit triggers another pipeline.** Check commit identification, webhook behavior, trigger filtering, and pipeline conditions.

![Troubleshooting Example](./media/screenshots/troubleshooting-example.png)
*A real failure encountered during implementation, and the fix applied.*

---

## Engineering Decisions

**Multibranch instead of individual jobs:** a Multibranch Pipeline provides a scalable mechanism for branch-aware CI/CD, instead of maintaining a separate Jenkins job per branch by hand.

**Credentials instead of hard-coded secrets:** sensitive values belong in Jenkins' credential-management system rather than source code.

**Webhooks instead of manual builds:** repository events provide a more responsive CI/CD workflow than polling or manual triggers.

**Automated versioning:** automating version changes reduces manual intervention and keeps versioning consistent.

**Recursive trigger protection:** automated Git writes are separated from developer-originated pipeline triggers to prevent feedback loops.

---

## Lessons Learned

This project reinforced how Multibranch discovery behaves in practice, how to design pipeline logic that adapts cleanly per branch, secure credential handling within Jenkins, webhook configuration and troubleshooting, and the discipline required to automate version commits without creating an infinite build loop.

The recursive-trigger problem in particular was the most instructive part of the project: solving it required treating Jenkins' own commits as first-class events to detect and filter, not just an edge case to patch around.

---

## Future Improvements

* Automated testing of Jenkinsfiles.
* Shared Library integration.
* Semantic versioning automation.
* Automated release tagging.
* Artifact promotion.
* Container image scanning.
* Security scanning.
* Deployment to Kubernetes.
* GitOps-based deployment.
* Pipeline observability.
* Automated rollback.
* Progressive delivery.
* Approval gates for production environments.

---

## Related Projects

**Jenkins CI Pipeline:** [jenkins-ci-pipeline](https://github.com/Chukwuemeka-Peter-Eze/jenkins-ci-pipeline)

**Jenkins Shared Library:** [jenkins-shared-library](https://github.com/Chukwuemeka-Peter-Eze/jenkins-shared-library)

---

## Connect

**GitHub:** https://github.com/Chukwuemeka-Peter-Eze
**LinkedIn:** https://www.linkedin.com/in/chukwuemekapetereze/

If you found this repository useful, consider giving it a star.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.