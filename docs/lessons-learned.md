# Lessons Learned

## Designing for the recursive-trigger problem before writing the versioning code

The most instructive part of this project wasn't any individual stage, it was realizing during planning that an automated version-commit creates a feedback loop with a webhook-triggered pipeline: the pipeline's own commit becomes a push event, which triggers the pipeline again. Solving this after the fact, once versioning and webhooks already existed, would have meant debugging a live infinite-build loop under pressure. Solving it during design meant the commit-tagging and skip-check logic could be built in from the start, and tested deliberately rather than discovered by accident.

## Credentials belong in Jenkins, not in branches or environment logic

Every credential this pipeline needs (Docker registry, SSH deploy key, GitHub PAT) is referenced only by ID in the Jenkinsfile. None of them are ever echoed, logged, or passed as plain shell arguments outside a `withCredentials` block. This matters more in a multibranch setup than a single pipeline, since every branch's Jenkinsfile pulls from the same credential store, a mistake in one branch's logic could expose a secret that every other branch also depends on.

## Separating the build server from the deploy target

Jenkins builds and pushes images; a separate server pulls and runs them. Keeping these as two distinct machines, rather than deploying onto the Jenkins host itself, makes the deploy step closer to how a real environment is structured (CI infrastructure and runtime infrastructure are rarely the same box) and makes it much easier to reason about what has access to what.

## Branch-based conditionals need to be decided deliberately, not organically

Deciding upfront that `feature/*` branches only test and build, `develop` builds and publishes, and only `main` deploys, meant the `when` conditions in the Jenkinsfile could be written once and stay consistent, instead of accumulating ad hoc branch checks stage by stage as new requirements came up.

## Documentation as part of the build, not an afterthought

Writing the architecture and design docs before every stage was fully implemented, then updating them as each stage landed, made it much easier to keep the Jenkinsfile and the documentation honest about what actually worked versus what was still planned. Retrofitting documentation onto a finished pipeline tends to describe the happy path; documenting alongside the build captures the actual decisions and trade-offs made along the way.