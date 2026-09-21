# Webhook Automation

## Why a webhook instead of polling

Jenkins can check a repository for changes on a schedule (polling) or wait for the repository to notify it directly (a webhook). Polling means either wasted checks when nothing changed, or a delay between a push and the pipeline noticing it, whichever interval is chosen is a trade-off. A webhook removes that trade-off entirely: GitHub tells Jenkins the moment a push happens, and the pipeline starts immediately.

## How it's wired up

```text
Developer pushes to GitHub
        ↓
GitHub sends a POST request to Jenkins' webhook endpoint
        ↓
Jenkins' GitHub plugin receives the payload
        ↓
Jenkins identifies which repository and branch it affects
        ↓
The corresponding Multibranch Pipeline job triggers a build
```

**GitHub side:** Repository → Settings → Webhooks → Add webhook, payload URL `http://<jenkins-url>/github-webhook/`, content type `application/json`, triggered on push events.

**Jenkins side:** the Multibranch Pipeline job needs "GitHub hook trigger for GITScm polling" (or the branch source's built-in webhook handling, depending on plugin version) enabled so it actually listens for the incoming hook rather than ignoring it.

## Security considerations

A webhook endpoint is a public entry point into the CI system, and it's worth treating it that way rather than as an implementation detail:

- **Network exposure:** Jenkins needs to be reachable from GitHub's servers, which usually means either a public IP with a restricted security group, or a reverse proxy in front of Jenkins rather than exposing the Jenkins port directly.
- **Payload validation:** GitHub supports signing webhook payloads with a shared secret. Configuring this (and having Jenkins verify the signature) prevents a third party from sending forged trigger requests to the same endpoint.
- **Least exposure:** the webhook only needs to reach the one endpoint that handles GitHub events, nothing else about Jenkins needs to be publicly reachable because of this feature.
- **Logging:** Jenkins logs incoming webhook deliveries, worth checking periodically for delivery attempts that don't correspond to an expected push, which can be an early signal of a misconfigured integration or something worth investigating further.

## Testing a webhook without waiting for a real push

GitHub's webhook settings page keeps a delivery history and includes a "Redeliver" button for any past delivery. This is the fastest way to confirm Jenkins is receiving and correctly processing the payload without needing to make a throwaway commit every time something is being debugged.