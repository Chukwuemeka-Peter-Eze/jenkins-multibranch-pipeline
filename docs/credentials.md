# Jenkins Credentials Setup

This pipeline needs three credentials stored in Jenkins. None of them are ever written directly into the Jenkinsfile, only their credential IDs are, the actual secrets stay inside Jenkins' credential store.

All credentials are added under:
**Manage Jenkins → Credentials → (global) → Add Credentials**

---

## 1. Docker Hub credential

Used to authenticate and push the built image.

| Field | Value |
|---|---|
| Kind | Username with password |
| Username | Your Docker Hub username |
| Password | Your Docker Hub password or access token |
| ID | `Docker-Hub-Credentials` |

The ID must match `DOCKER_CREDENTIALS_ID` in the Jenkinsfile exactly.

---

## 2. SSH credential for the deployment server

Used by the `Deploy` stage to connect to the target server. See `docs/setup.md` for generating this key pair first.

| Field | Value |
|---|---|
| Kind | SSH Username with private key |
| Username | `ubuntu` |
| Private Key | "Enter directly", paste the full contents of `jenkins_deploy` (including the `-----BEGIN/END-----` lines) |
| ID | `deploy-ssh-credentials` |

Verify the manual SSH connection from `docs/setup.md` step 7 succeeds *before* wiring this up, it isolates whether a problem is in the SSH setup or in Jenkins' use of it.

---

## 3. GitHub Personal Access Token

Used by the `Commit Version Change` stage to push the version bump back to the repository.

**Generate the token:**
GitHub → Settings → Developer settings → Personal access tokens → Generate new token (classic is simplest) → scope: `repo`

**Add it to Jenkins:**

| Field | Value |
|---|---|
| Kind | Username with password |
| Username | Your GitHub username |
| Password | The generated token |
| ID | `GitHub-PAT` |

The ID must match `GIT_CREDENTIALS_ID` in the Jenkinsfile exactly. Keep the token scoped to `repo` only, and treat it like a password, it grants write access to your repositories.

---

## Verifying an ID match

If the Jenkinsfile says:

```groovy
DOCKER_CREDENTIALS_ID = 'Docker-Hub-Credentials'
```

then the credential in Jenkins must have exactly that ID, character for character. A mismatch here is one of the most common pipeline failures, and the error message (`credentials not found`) points straight back to this file.