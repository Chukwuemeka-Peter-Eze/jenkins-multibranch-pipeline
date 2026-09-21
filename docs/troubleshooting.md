# Troubleshooting

This is a reference guide to the failure modes this kind of pipeline commonly hits, organized by stage. As real issues come up during ongoing use of this pipeline, they'll be added here with the actual console output and the specific fix, the same way `jenkins-ci-pipeline`'s troubleshooting section documents real errors encountered during that build.

---

### Branch not discovered by the Multibranch job

**Likely cause:** branch discovery strategy in the Jenkins job configuration doesn't include the branch type being pushed, or Jenkins hasn't re-indexed since the branch was created.

**Check:** Job Configuration → Branch Sources → Discover branches setting. Trigger a manual "Scan Repository Now" to force re-indexing.

---

### Webhook push doesn't trigger a build

**Likely cause:** the payload URL is wrong, Jenkins isn't reachable from the public internet (common on a fresh EC2 setup without the right security group rule or a reverse proxy), or the webhook is configured for the wrong event type.

**Check:** GitHub repo → Settings → Webhooks → Recent Deliveries, to see whether GitHub even reached Jenkins and what response code came back. A red X with a connection error usually means a networking or security group problem, not a Jenkins configuration problem.

---

### `credentials not found` error

**Likely cause:** the credential ID in the Jenkinsfile doesn't exactly match the ID configured in Jenkins. This is the single most common failure in a pipeline with multiple credentials.

**Check:** Manage Jenkins → Credentials, compare each ID character for character against `DOCKER_CREDENTIALS_ID`, `DEPLOY_SSH_CREDENTIALS_ID`, and `GIT_CREDENTIALS_ID` in the Jenkinsfile's `environment {}` block.

---

### `Increment Version` stage fails to parse the version

**Likely cause:** `pom.xml`'s `<version>` isn't in plain `major.minor.patch` format, for example it still has a `-SNAPSHOT` suffix, which breaks the integer parsing this pipeline's patch-bump logic depends on.

**Check:** confirm `pom.xml` has a clean version like `1.1.0`, not `1.1.0-SNAPSHOT`.

---

### SSH deploy step hangs or fails with permission denied

**Likely cause:** the dedicated Jenkins SSH key isn't authorized on the deployment server yet, or the manual SSH test was never confirmed working before wiring up the Jenkins credential.

**Check:** SSH manually from the Jenkins server using the exact same key Jenkins uses (`ssh -i ~/.ssh/jenkins_deploy ubuntu@DEPLOY_HOST`) before assuming the problem is in Jenkins.

---

### `git push` rejected during the version-commit stage

**Likely cause:** another commit landed on the branch between the pipeline checking out the code and it trying to push the version bump, a non-fast-forward rejection.

**Check:** the pipeline's Git checkout should be recent enough that this is rare, but if it happens repeatedly, consider adding a `git pull --rebase` immediately before the commit-and-push step.

---

### Pipeline runs twice for what looks like one push

**Likely cause:** the recursive-trigger check isn't matching the commit message correctly, often because the `VERSION_COMMIT_TAG` string was changed in one place but not the other, or the commit message got truncated somewhere.

**Check:** compare the exact string in `VERSION_COMMIT_TAG` against what actually appears in `git log -1 --pretty=%B` on the commit that triggered the second run.