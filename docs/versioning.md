# Application Versioning

## Approach

This pipeline uses semantic versioning (`major.minor.patch`) and automatically increments the **patch** number on every build to `main` or `develop`. Major and minor bumps are intentionally left as manual decisions, patch-only automation is the safer default: it never accidentally jumps a version number in a way that implies a breaking or feature change when the pipeline can't actually know that.

```text
1.1.0  →  1.1.1  →  1.1.2  →  1.1.3 ...
```

## Why not SNAPSHOT versioning

Maven's `-SNAPSHOT` convention marks a version as mutable, the same SNAPSHOT version can be rebuilt and redeployed many times, overwriting what came before in a shared repository. That model conflicts with what this pipeline does: every build produces a specific, immutable, traceable version that gets tagged, published, and committed back to Git. Using plain release-style versions (`1.1.0`, not `1.1.0-SNAPSHOT`) keeps that traceability intact, every Docker image tag corresponds to exactly one commit and one pom.xml version.

## How the version is read and incremented

```groovy
env.CURRENT_VERSION = sh(
    script: "mvn -q help:evaluate -Dexpression=project.version -DforceStdout",
    returnStdout: true
).trim()
```

This uses Maven's own `help:evaluate` goal to read `project.version` directly from `pom.xml`, rather than parsing the XML manually, which is more reliable across formatting differences.

The increment itself splits the version string on `.` and increments the last segment:

```groovy
def parts = env.CURRENT_VERSION.tokenize('.')
def patch = (parts[2] as Integer) + 1
env.NEW_VERSION = "${parts[0]}.${parts[1]}.${patch}"
```

The new version is then written back into `pom.xml` using the `versions-maven-plugin`, invoked with its fully qualified coordinates so it works without needing to be declared in the `pom.xml` itself:

```bash
mvn org.codehaus.mojo:versions-maven-plugin:2.16.2:set -DnewVersion=1.1.1 -DgenerateBackupPoms=false
```

## How the Docker tag stays aligned

The Docker image tag is built directly from the same `NEW_VERSION` variable used to update `pom.xml`, so there's no separate versioning logic to keep in sync:

```groovy
env.IMAGE_TAG = "${DOCKER_REGISTRY}/${APP_NAME}:${env.NEW_VERSION}"
```

## What a manual major/minor bump would look like

Not implemented yet, but the natural extension: check the triggering commit message for a marker like `[minor]` or `[major]` (similar to how `[jenkins-skip]` is already checked for recursive-trigger prevention), and branch the increment logic accordingly instead of always bumping the patch number.