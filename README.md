# Jenkins Multibranch Pipeline

> Automated branch-aware CI/CD workflows using Jenkins Multibranch Pipelines, secure credentials, Git webhooks, and automated application version management.

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins&logoColor=white)](#)
[![Pipeline](https://img.shields.io/badge/Jenkins-Pipeline-blue?logo=jenkins&logoColor=white)](#)
[![Git](https://img.shields.io/badge/Git-Version%20Control-orange?logo=git&logoColor=white)](#)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Automation-green)](#)
[![Documentation](https://img.shields.io/badge/Documentation-PECOS-informational)](#)

---

## Table of Contents

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
* [Technology Stack](#technology-stack)
* [Repository Structure](#repository-structure)
* [Implementation](#implementation)
* [Validation](#validation)
* [Evidence](#evidence)
* [Security Considerations](#security-considerations)
* [Troubleshooting](#troubleshooting)
* [Engineering Decisions](#engineering-decisions)
* [Lessons Learned](#lessons-learned)
* [Future Improvements](#future-improvements)
* [Related Projects](#related-projects)
* [Connect](#connect)
* [Project Status](#project-status)
* [License](#license)

---

## Overview

Modern application repositories commonly contain multiple branches representing different stages of development and delivery. A CI/CD system must be capable of discovering these branches, executing the appropriate pipeline logic, responding to repository changes, securely accessing required resources, and managing application versions consistently.

This project demonstrates a Jenkins-based approach using Multibranch Pipelines, branch-aware Jenkinsfiles, Jenkins Credentials, Git webhooks, automated application versioning, Docker image version alignment, automated commits from Jenkins, and protection against recursive pipeline execution.

The result is a branch-aware CI/CD workflow that connects source-control activity with automated build and delivery processes.

---

## Engineering Problem

A single static Jenkins pipeline becomes increasingly difficult to manage when a repository contains multiple active branches. Different branches may require different behavior:

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

This project combines several Jenkins capabilities into one workflow.

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

![Jenkins Multibranch Pipeline Architecture](./media/diagrams/jenkins-multibranch-architecture.png)

> **Architecture placeholder:** replace this image with the final diagram after implementation is complete and validated.

### Conceptual Architecture

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

> Screenshot placeholder.

---

## Branch-Based Pipeline Logic

The pipeline inspects the current branch and applies branch-specific behavior.

```text
if main
    → production-oriented workflow

if develop
    → integration workflow

if feature/*
    → validation workflow
```

The exact branch names and behavior should reflect the implementation actually completed.

![Branch-Based Pipeline Logic](./media/screenshots/branch-based-logic.png)

> Screenshot placeholder.

---

## Credentials Management

CI/CD pipelines frequently require authentication to external systems: source-control repositories, container registries, artifact repositories, cloud platforms, and deployment targets.

Credentials should never be hard-coded into Jenkinsfiles. Instead, Jenkins Credentials provide controlled access to sensitive values.

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

> Screenshot placeholder. Never commit screenshots containing actual secrets.

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

> Screenshot placeholder.

**Security considerations:** authentication, secret tokens where supported, source validation, network exposure, Jenkins security configuration, and logging/monitoring all matter here, a webhook endpoint is an entry point into your CI system.

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

This project explores incrementing the application version both locally and within the Jenkins Pipeline itself.

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

> Screenshot placeholder.

---

## Docker Image Versioning

The application version should be reflected in the container image strategy:

```text
Application Version
        │
        ▼
Docker Image Tag
```

The Dockerfile and pipeline configuration need to stay aligned with the versioning strategy.

---

## Version Commit Workflow

A complete automated versioning workflow may require Jenkins to commit the updated version back to the Git repository.

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

> Screenshot placeholder.

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

This has to be intentionally controlled.

**Desired behavior:**

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
Pipeline execution ignored
```

This is a core part of the project's engineering design, not just a configuration detail.

---

## Technology Stack

| Technology                   | Purpose                                  |
| ----------------------------- | ------------------------------------------ |
| Jenkins                      | CI/CD orchestration                      |
| Jenkins Pipeline             | Pipeline-as-code                         |
| Jenkins Multibranch Pipeline | Branch-aware automation                  |
| Git                          | Source control                           |
| GitHub                       | Repository hosting and webhook source    |
| Groovy                       | Jenkins pipeline implementation          |
| Maven                        | Application build and version management |
| Docker                       | Container image creation                 |

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
│
├── docs/
│   ├── setup.md
│   ├── commands.md
│   ├── credentials.md
│   ├── webhooks.md
│   ├── versioning.md
│   ├── troubleshooting.md
│   └── lessons-learned.md
│
├── media/
│   ├── screenshots/
│   ├── diagrams/
│   └── gifs/
│
└── videos/
    └── video-script.md
```

> Source files are intentionally represented as planned components until the hands-on implementation is completed.

---

## Implementation

The implementation will be documented through the following stages:

**Stage 1: Repository Preparation.** Configure the source repository and Jenkinsfile.

**Stage 2: Multibranch Configuration.** Configure Jenkins to discover repository branches.

**Stage 3: Branch Logic.** Implement branch-aware pipeline behavior.

**Stage 4: Credentials.** Configure Jenkins credentials required by the pipeline.

**Stage 5: Webhook.** Configure repository events to notify Jenkins.

**Stage 6: Application Versioning.** Implement version incrementing and validation.

**Stage 7: Docker Image.** Align the container image with the application version.

**Stage 8: Git Version Commit.** Allow Jenkins to commit the version update where required.

**Stage 9: Trigger Protection.** Prevent Jenkins-generated commits from recursively starting another pipeline execution.

**Stage 10: Validation.** Run the complete workflow and capture evidence.

---

## Validation

The completed workflow should demonstrate:

* [ ] Branch discovery works.
* [ ] Jenkinsfile is loaded from the appropriate branch.
* [ ] Branch-specific logic executes correctly.
* [ ] Required credentials are available.
* [ ] Credentials are not exposed in logs.
* [ ] Webhook triggers the appropriate pipeline.
* [ ] Application version can be incremented.
* [ ] Pipeline can perform the version update.
* [ ] Docker image reflects the intended version.
* [ ] Jenkins can commit the version update where configured.
* [ ] Jenkins-generated commits do not recursively trigger the pipeline.
* [ ] Complete workflow succeeds.

---

## Evidence

| Evidence                       | Status    |
| -------------------------------- | ----------- |
| Multibranch configuration      | ⬜ Pending |
| Branch discovery               | ⬜ Pending |
| Branch-based Jenkinsfile logic | ⬜ Pending |
| Credentials configuration      | ⬜ Pending |
| Successful credential usage    | ⬜ Pending |
| Git webhook configuration      | ⬜ Pending |
| Webhook-triggered build        | ⬜ Pending |
| Application version increment  | ⬜ Pending |
| Docker version alignment       | ⬜ Pending |
| Jenkins Git commit             | ⬜ Pending |
| Recursive-trigger prevention   | ⬜ Pending |
| Complete pipeline execution    | ⬜ Pending |
| Architecture diagram           | ⬜ Pending |
| Video demonstration            | ⬜ Pending |

---

## Security Considerations

This project involves credentials and automated write access to Git, making security particularly important.

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

**Branch not discovered.** Check repository configuration, branch discovery strategy, repository permissions, Jenkins credentials, and Jenkins indexing logs.

**Webhook does not trigger Jenkins.** Check webhook configuration, target URL, Jenkins accessibility, event type, authentication/secret configuration, and Jenkins logs.

**Credential authentication fails.** Check the credential ID, credential type, permissions, repository access, and credential scope.

**Version is not updated.** Check the build configuration, Maven configuration, version expression, pipeline stage ordering, and Git working tree.

**Jenkins commit triggers another pipeline.** Check commit identification, webhook behavior, trigger filtering, and pipeline conditions.

Detailed investigation procedures are documented separately in `docs/troubleshooting.md`.

---

## Engineering Decisions

**Multibranch instead of individual jobs:** a Multibranch Pipeline provides a scalable mechanism for branch-aware CI/CD, instead of maintaining a separate Jenkins job per branch by hand.

**Credentials instead of hard-coded secrets:** sensitive values belong in Jenkins' credential-management system rather than source code.

**Webhooks instead of manual builds:** repository events provide a more responsive CI/CD workflow than polling or manual triggers.

**Automated versioning:** automating version changes reduces manual intervention and keeps versioning consistent.

**Recursive trigger protection:** automated Git writes must be separated from developer-originated pipeline triggers to prevent feedback loops.

---

## Lessons Learned

This section will be completed after hands-on implementation. Planned to document: Multibranch discovery behavior, branch-specific pipeline design, credential handling, webhook troubleshooting, versioning behavior, Git automation, recursive-trigger prevention, Jenkins debugging techniques, and production considerations.

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

**Jenkins CI/CD Pipeline:** [jenkins-cicd-pipeline](https://github.com/Chukwuemeka-Peter-Eze/jenkins-cicd-pipeline)

**Jenkins Shared Library:** [jenkins-shared-library](https://github.com/Chukwuemeka-Peter-Eze/jenkins-shared-library)

**Portfolio Website:** [chukwuemekapetereze.online](https://www.chukwuemekapetereze.online)

---

## Connect

**GitHub:** https://github.com/Chukwuemeka-Peter-Eze
**LinkedIn:** https://www.linkedin.com/in/chukwuemekapetereze/
**Portfolio:** https://www.chukwuemekapetereze.online

---

## Project Status

| Component                  | Status                  |
| ----------------------------- | -------------------------- |
| Repository                 | ✅ Created               |
| Documentation framework    | ✅ In progress           |
| Source code                | ⏳ To be added           |
| Multibranch implementation | ⏳ Pending hands-on work |
| Credentials                | ⏳ Pending hands-on work |
| Webhooks                   | ⏳ Pending hands-on work |
| Versioning                 | ⏳ Pending hands-on work |
| Architecture diagram       | ⏳ Pending               |
| Screenshots                | ⏳ Pending               |
| Video                      | ⏳ Pending               |
| Final retrospective        | ⏳ Pending               |

This repository follows a documentation-first workflow. Implementation evidence will be added after the corresponding engineering work has been completed.

---

## License

[LICENSE INFORMATION, PLACEHOLDER]