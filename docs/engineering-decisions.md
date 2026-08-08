# Engineering Decisions

## Multibranch Pipeline

**Decision:** Use a Multibranch Pipeline for branch-aware automation.

**Reason:** Avoid maintaining separate manually configured jobs for every branch.

---

## Webhook Triggering

**Decision:** Use repository events to initiate pipeline execution.

**Reason:** Reduce dependence on manual pipeline execution.

---

## Credentials Store

**Decision:** Store sensitive values in Jenkins Credentials.

**Reason:** Keep secrets outside source-controlled pipeline code.

---

## Automated Versioning

**Decision:** Manage application version changes through the pipeline.

**Reason:** Improve consistency and reduce manual release operations.

---

## Trigger Protection

**Decision:** Explicitly prevent Jenkins-generated commits from recursively triggering the pipeline.

**Reason:** Avoid uncontrolled build loops.