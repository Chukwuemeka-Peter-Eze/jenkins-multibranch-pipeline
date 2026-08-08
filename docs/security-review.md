# Security Review

## Credential Security

* [ ] No credentials committed to Git
* [ ] Jenkins Credentials used
* [ ] Least privilege applied
* [ ] Secrets masked in logs

## Webhook Security

* [ ] Endpoint protected
* [ ] Authentication configured where appropriate
* [ ] Webhook secret protected
* [ ] Untrusted requests controlled

## Git Write Access

The Jenkins identity used to commit version changes should have only the permissions required to perform the intended operation.

## Pipeline Security

Review:

* User-controlled parameters
* Shell commands
* Credential usage
* Branch permissions
* Automated Git operations