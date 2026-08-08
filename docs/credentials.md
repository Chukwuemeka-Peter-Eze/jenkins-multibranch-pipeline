# Jenkins Credentials

## Purpose

Jenkins Credentials provide controlled access to sensitive information required by automated pipelines.

Typical credentials may include:

* Username/password
* SSH keys
* Access tokens
* Registry credentials
* Repository credentials

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

## Configuration Evidence

![Jenkins Credentials Configuration](../media/screenshots/credentials.png)

> Placeholder — replace with a screenshot that contains no exposed secrets.

## Validation

* [ ] Credential created
* [ ] Correct credential type selected
* [ ] Correct scope selected
* [ ] Pipeline references credential
* [ ] Authentication succeeds
* [ ] Secret does not appear in logs
