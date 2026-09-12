# Troubleshooting Guide

## Table of Contents

* [Branch Not Discovered](#branch-not-discovered)
* [Webhook Does Not Trigger Pipeline](#webhook-does-not-trigger-pipeline)
* [Git Authentication Failure](#git-authentication-failure)
* [Maven Version Update Fails](#maven-version-update-fails)
* [Docker Image Has Wrong Version](#docker-image-has-wrong-version)
* [Jenkins Commit Triggers Pipeline Again](#jenkins-commit-triggers-pipeline-again)

---

## Branch Not Discovered

**Possible causes:** repository credentials, branch discovery configuration, repository permissions, Jenkins indexing, or an incorrect repository URL.

**Investigation:** check Jenkins indexing logs and repository accessibility.

---

## Webhook Does Not Trigger Pipeline

**Possible causes:** incorrect endpoint, Jenkins not reachable, incorrect event type, an authentication issue, or a Jenkins configuration issue.

**Investigation:** check webhook delivery information and Jenkins logs.

---

## Git Authentication Failure

Check the credential ID, credential type, repository permissions, branch permissions, and the remote URL.

---

## Maven Version Update Fails

Check the Maven installation, project configuration, version expression, plugin configuration, and working tree state.

---

## Docker Image Has Wrong Version

Check the application version, Docker build arguments, Dockerfile, image tagging logic, and pipeline environment variables.

---

## Jenkins Commit Triggers Pipeline Again

**Problem:** the pipeline modifies the repository and pushes a commit, which creates another webhook event.

**Investigation:** determine whether the pipeline can identify its own generated commit.

**Resolution:** implement an explicit mechanism to ignore Jenkins-generated version commits.

The exact implementation should be documented after the hands-on configuration.