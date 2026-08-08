# Frequently Asked Questions

### What is a Multibranch Pipeline?

A Jenkins pipeline model designed to discover and execute pipeline definitions across multiple source-control branches.

### Why use Multibranch instead of separate jobs?

It provides a scalable branch-aware structure and reduces repetitive Jenkins job configuration.

### Why use webhooks?

Webhooks allow repository events to initiate CI/CD workflows automatically.

### Why shouldn't credentials be stored in Jenkinsfiles?

Source-controlled pipeline files can be viewed or copied. Sensitive credentials should therefore be managed through a dedicated credential system.

### Why is automated versioning useful?

It creates a consistent mechanism for associating application versions with builds and artifacts.

### Why can automated versioning cause a loop?

If Jenkins commits the version change back to Git, that commit can generate another repository event and potentially start another pipeline.

### How should that loop be handled?

The pipeline should explicitly distinguish Jenkins-generated version commits from normal developer changes and prevent unintended recursive execution.