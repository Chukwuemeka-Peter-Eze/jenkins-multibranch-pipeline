# Video Script - Jenkins Multibranch Pipeline

## Opening

**Visual:** Repository and Jenkins dashboard.

> "In this project, I built a branch-aware CI/CD workflow using Jenkins Multibranch Pipelines, secure credentials, Git webhooks, and automated application version management."

## Part 1 — Architecture

Show the architecture diagram.

Explain:

* Git repository
* Branches
* Webhook
* Jenkins
* Multibranch Pipeline
* Build
* Versioning
* Docker
* Git commit

## Part 2 — Multibranch Pipeline

Show branch discovery.

Demonstrate how Jenkins identifies the branches.

## Part 3 — Credentials

Show the credential configuration without exposing sensitive information.

Explain why credentials are managed outside the Jenkinsfile.

## Part 4 — Webhook

Make a repository change.

Show the webhook event.

Show Jenkins receiving the event.

## Part 5 — Versioning

Show the initial version.

Trigger the pipeline.

Show the updated version.

## Part 6 — Docker

Show the resulting image and version relationship.

## Part 7 — Git Commit

Show the automated version commit.

## Part 8 — Trigger Protection

Explain why the Jenkins-generated commit does not cause an uncontrolled recursive build.

## Closing

Summarize the engineering principles demonstrated:

* Branch-aware automation
* Secure credential management
* Event-driven CI/CD
* Automated versioning
* Controlled Git automation
* Recursive-trigger prevention