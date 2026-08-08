# Jenkins Webhooks

## Purpose

Webhooks allow the source-control platform to notify Jenkins when repository activity occurs.

## Workflow

```text
Git Push
   ↓
Webhook
   ↓
Jenkins
   ↓
Multibranch Pipeline
   ↓
Branch Build
```

## Configuration

Document:

* Webhook endpoint
* Event type
* Authentication mechanism
* Jenkins configuration
* Branch behavior

> Do not publish webhook secrets.

## Evidence

![Webhook Configuration](../media/screenshots/webhook.png)

![Webhook Triggered Build](../media/screenshots/webhook-build.png)

## Validation

* [ ] Webhook configured
* [ ] Correct event selected
* [ ] Jenkins receives event
* [ ] Appropriate branch identified
* [ ] Pipeline starts
* [ ] Pipeline completes successfully