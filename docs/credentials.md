# Jenkins Credentials

## Table of Contents

* [Purpose](#purpose)
* [Security Principle](#security-principle)
* [Configuration Evidence](#configuration-evidence)
* [Validation](#validation)

---

## Purpose

Jenkins Credentials provide controlled access to sensitive information required by automated pipelines. Typical credentials may include username/password pairs, SSH keys, access tokens, registry credentials, and repository credentials.

---

## Security Principle

Credentials should be referenced by identifier rather than embedded directly inside pipeline code.

```text
Jenkinsfile
     │
     ▼
Credential ID
     │
     ▼
Jenkins Credentials Store
     │
     ▼
Authenticated operation
```

---

## Configuration Evidence

![Jenkins Credentials Configuration](../media/screenshots/credentials.png)

---

## Validation

* [ ] Credential created.
* [ ] Correct credential type selected.
* [ ] Correct scope selected.
* [ ] Pipeline references the credential.
* [ ] Authentication succeeds.
* [ ] Secret does not appear in logs.