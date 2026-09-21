# Webhook Automation

## Why Use a Webhook Instead of Polling?

Jenkins can detect repository changes by periodically polling GitHub or by receiving webhook notifications.

Polling requires Jenkins to repeatedly ask whether anything has changed:

```text
Jenkins → Has anything changed?
Jenkins → Has anything changed?
Jenkins → Has anything changed?
```

The polling interval creates a trade-off between responsiveness and unnecessary requests.

A webhook reverses the model:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   │ webhook
   ▼
Jenkins
```

GitHub notifies Jenkins when a relevant repository event occurs, allowing the Multibranch Pipeline to react to the change.

For this project, GitHub webhooks are used to trigger the Jenkins Multibranch Pipeline after repository changes.

---

# How the Webhook Is Wired

The overall flow is:

```text
Developer pushes to GitHub
        ↓
GitHub creates a push event
        ↓
GitHub sends webhook payload to Jenkins
        ↓
Jenkins receives the event
        ↓
Jenkins identifies the repository/branch
        ↓
Multibranch Pipeline evaluates the branch
        ↓
Corresponding pipeline execution starts
```

The Multibranch Pipeline then applies the branch-specific logic defined in the Jenkinsfile.

---

# GitHub Configuration

In the GitHub repository:

**Settings → Webhooks → Add webhook**

Configure the webhook to point to the Jenkins GitHub webhook endpoint:

```text
http://<jenkins-url>/github-webhook/
```

Use:

```text
Content type:
application/json
```

For this project, the webhook is primarily concerned with repository push events.

After saving the webhook, GitHub provides delivery history that can be used to verify whether Jenkins received the request.

---

# Jenkins Configuration

The exact Jenkins configuration depends on the installed GitHub and Multibranch Pipeline plugins.

The Multibranch Pipeline must be configured so that GitHub repository events can trigger branch indexing/build activity.

Depending on the Jenkins/plugin configuration, this may involve:

* GitHub branch-source webhook handling
* GitHub hook trigger support
* Multibranch branch-source configuration

The important requirement is that the Jenkins Multibranch Pipeline is actually listening for the GitHub event.

---

# Testing the Webhook

GitHub provides a delivery history for each webhook.

Open:

**GitHub → Repository → Settings → Webhooks → Your Webhook → Recent Deliveries**

A successful delivery should show that GitHub was able to reach the configured Jenkins endpoint.

GitHub also provides a **Redeliver** option.

This is useful when debugging because it allows an existing webhook event to be sent again without creating another Git commit.

---

# Troubleshooting Webhook Delivery

If a push does not trigger Jenkins, check the problem in layers.

### 1. Check GitHub Delivery History

Look at:

**Recent Deliveries**

Confirm whether GitHub successfully contacted Jenkins.

### 2. Check Jenkins Accessibility

Jenkins must be reachable from GitHub's infrastructure.

If Jenkins is running on AWS, review the EC2 security group and networking configuration.

### 3. Check the Webhook URL

Verify that the URL points to the correct Jenkins endpoint:

```text
/github-webhook/
```

### 4. Check the Multibranch Job

Verify that the repository and branch are correctly configured in the Multibranch Pipeline.

### 5. Scan the Repository

If a newly created branch is not appearing, run:

**Scan Repository Now**

This forces Jenkins to re-index the repository.

---

# Webhook Security Considerations

A webhook endpoint is a public entry point into the CI system and should be treated as a security-sensitive integration.

## Network Exposure

Jenkins needs to be reachable by GitHub for webhook delivery.

For a learning environment, Jenkins may be exposed through a public EC2 endpoint.

For a production environment, consider:

* Reverse proxy
* HTTPS
* Restrictive security groups
* Network controls
* Dedicated ingress infrastructure

The Jenkins administration interface should not be unnecessarily exposed to the entire internet.

---

## Webhook Secret

GitHub supports signing webhook payloads with a shared secret.

Where supported by the Jenkins integration, configure webhook signature validation so that Jenkins can distinguish legitimate GitHub webhook requests from forged requests.

---

## Least Exposure

Only the required webhook endpoint should be reachable for webhook delivery.

Do not expose additional Jenkins services or administrative interfaces simply because the webhook needs to reach Jenkins.

---

## Logging and Monitoring

Webhook delivery history should be reviewed when diagnosing unexpected builds.

Jenkins logs can also help determine whether:

* the webhook was received,
* the repository was identified,
* a branch was discovered,
* a build was scheduled.

---

# Webhooks and Recursive Pipeline Execution

This project contains an important interaction between webhooks and automated version commits.

The `main` and `develop` pipelines update `pom.xml` and commit the new version back to GitHub.

That commit generates another GitHub push event:

```text
Pipeline
   ↓
Version bump
   ↓
Git commit
   ↓
GitHub push event
   ↓
Webhook
   ↓
Jenkins
```

The pipeline prevents this from becoming a recursive build loop by marking its automated commit:

```text
[jenkins-skip]
```

The next Jenkins execution checks the latest commit message.

If the marker is present, the remaining pipeline stages are skipped.

This is an important example of why webhook-driven automation must account for changes generated by the automation itself.

---

# Final Webhook Flow

The complete project flow is:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   │ webhook
   ▼
Jenkins Multibranch Pipeline
   │
   ├── feature/* → Test → Build
   │
   ├── develop → Test → Version → Build → Docker → Push → Commit
   │
   └── main → Test → Version → Build → Docker → Push → Deploy → Commit
                                                  │
                                                  ▼
                                           Deployment Target
```

This creates an event-driven CI/CD workflow rather than relying on scheduled repository polling.