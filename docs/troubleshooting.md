# Troubleshooting Guide

## Branch Not Discovered

### Possible Causes

* Repository credentials
* Branch discovery configuration
* Repository permissions
* Jenkins indexing
* Incorrect repository URL

### Investigation

Check Jenkins indexing logs and repository accessibility.

---

## Webhook Does Not Trigger Pipeline

### Possible Causes

* Incorrect endpoint
* Jenkins not reachable
* Incorrect event
* Authentication issue
* Jenkins configuration issue

### Investigation

Check webhook delivery information and Jenkins logs.

---

## Git Authentication Failure

Check:

* Credential ID
* Credential type
* Repository permissions
* Branch permissions
* Remote URL

---

## Maven Version Update Fails

Check:

* Maven installation
* Project configuration
* Version expression
* Plugin configuration
* Working tree state

---

## Docker Image Has Wrong Version

Check:

* Application version
* Docker build arguments
* Dockerfile
* Image tagging logic
* Pipeline environment variables

---

## Jenkins Commit Triggers Pipeline Again

### Problem

The pipeline modifies the repository and pushes a commit, which creates another webhook event.

### Investigation

Determine whether the pipeline can identify its own generated commit.

### Resolution

Implement an explicit mechanism to ignore Jenkins-generated version commits.

The exact implementation should be documented after the hands-on configuration.