# Example AWS RBAC Implementation in Terraform

An example RBAC implementation for an online service

## Design Overview
I wanted to build a system that was as self-service as possible in the time frame.  I make some assumptions about what is already existing in the environment in order to get started.  I also postpone some work to the future, as it would not be possible to complete in the two hour time limit provided.

The overall design is to create IAM Groups to represent teams, which have managed policies attached to them.

## Assumptions
- I am assuming that for "access to" means "full access to," and am using the relevant AWS-managed Roles.  However, in the real world I would want to understand more about how the teams use it, to see if full access is actually required vs. read-only access.
- I assume all stdout and other relevant logs from the Jenkins build host is being sent to some kind of logging solution
- That there is a prometheus cluster somewhere setup
- There is an existing Jenkins setup to receive the commit hook and run the Jenkinsfile, configured with the logging / metrics requirements above
- This existing Jenkins setup is emitting Prometheus metrics about job runs
	- https://plugins.jenkins.io/prometheus/

## Pre-requisites
In order to use this solution, it is assumed there already exists a functional AWS account, meeting the following requirements:
- There is an existing S3 bucket designated for Terraform state purposes.  This bucket should have S3 versioning enabled, however this is not necessary for functionality.
- There is an existing DynamoDB bucket designated for Terraform lock purposes
- This implementation does not deal with what AWS access EKS itself needs to operate.  E.g., AmazonEKSWorkerNodePolicy and friends, and assumes that an existing Role EKS clusters can use is already present and managed in this account.
- The Jenkins build system can via some means run the Jenkinsfile with appropriate permissions in the local (or correct trust with an external) AWS account.  This is likely an Admin or Build IAM Role.

# Important Links
Jenkins Build:  TBD  *(I was testing on my private home Jenkins server)*

# Instructions
## Instructions on how to Add a new user
1. A Base64 of the user's private GPG keypair is required.  This can be generated in any method desired; for example, install GnuPG and run:
```
    gpg --full-generate-key
    gpg --list-keys
    gpg --export 989296EB978E333BC8D6E8724876D98BA451E7FF |base64
```
3. Create a file under the folder public_gpg_keys named user.gpg.  Paste the base64 of the user's private GPG keypair here.
4. Add a user stanza for the user in main.tf, in the appropriate team location
5. Commit the change in a new branch, and submit a PR.  Once approved and merged into main, automation should kick off the Jenkins pipeline.
6. Once the pipeline has finished and changes have been applied, review the Jenkins build, click on the environment for the relevant stage (e.g., dev, stage, or prod), and click on the green Logs button.  Expand the "terraform apply" command subsection, and scroll through the outputs until you find the user credentials you are looking for.  Since the secret access key is encrypted, only the user should be able to decrypt, and so the information should be safe to send, or safe to have the user self-service retrieve.
7. If permitted, this entire process could be self-serviced by the end-user.  They add themselves to the appropriate group via the steps above, submit a PR to be approved, and once merged in, they could retrieve their access key and secret.

An example commit to add "example user" to frontend_engineers can be found here:  https://github.com/DranoTheCat/rbac-implementation-example/commit/9a5c6de44d2cf860dd0c6d27585351d3ae799354

This is a fairly ugly and dirty approach to self-service, but it gets the job done in the time constraint.

## Instructions on how to Remove an existing user
1. Remove the user's GPG key file.
2. Remove the user's stanza from main.tf
3. Commit the change in a new branch, and submit a PR.  Once approved and merged into main, automation should kick off the Jenkins pipeline.
4. The user should be removed after the pipeline finishes running.

An example commit to delete the "dhart" user can be found here:  https://github.com/DranoTheCat/rbac-implementation-example/commit/70c5993fb115919344d18a5541805267ed6ce3f7

## Considerations
### General Considerations
- Users should ideally authenticate with keys, not passwords.  In either case, however, key exchange becomes a problem.
- There are usually existing solutions to this problem that could be leveraged, however, this solution must assume such a solution is not already in place.  In addition, there is a 2hr time limit, so I've chosen a simple approach of having each user create a GPG key pair and provide the public half of it.  This way the encrypted key can be stored in terraform state relatively safely, and displayed as an output.  The user can then self-service retrieving their own key as described above, and only they should be able to decrypt it.  This isn't an ideal method of distribution, but prevents toil of needing an admin to provide the keys manually, and was achievable within the time limit.
### Cost Analysis
- Although there is a cost to S3 and DynamoDB, it is assumed this is part of overall infrastructure and not a part of this project.
- As such, this project should not incur any cost, as AWS IAM is provided free of charge to all AWS customers.
- If ever this project should scope up to include cost-incurring resources, cost modeling could be done by a tool like infracost
### Security
- Principal of least access is observed in specifying explicit eks clusters for the backend team.
- This is not true for the frontend and data engineers, who have AWS-managed policies which provide wildcard access to certain resources.  This could be locked down future by maintaining our own policies, however that seemed out of scope for the time limit.
- A good future improvement (see below) would be to add a tfsec stage in the Jenkins pipeline
- This implementation assumes the Jenkins build agent running terraform itself has admin access.  See enumerating explicit permissions in future improvements below.
- This implementation assumes management of the "aws-auth" ConfigMap is done out of scope of this implementation.  *This implementation currently only handles the IAM resources described in the requirements, however this is only sufficient for users to manage EKS clusters they themselves are the owners of.  Configuration of the "aws-auth" ConfigMap is required in addition to the IAM Role configuration provided here in order to access other EKS clusters in the account, which are valid targets, but that may not have been created by the same user.*
### Automation
- The Jenkins pipeline should be triggered from commits / merges to main branch
- Everything else is automated as code
### Monitoring
- It is assumed above that logs and metrics from Jenkins are going somewhere else, where a dashboard for this could be created
- Likewise, alerts could be driven from these metrics with AlertManager directly, or feeding into PagerDuty, Slack, etc.
### Logging
- Per assumptions above, it is assumed all of the relevant logs from Jenkins are already configured to go to a remote site.
- Secrets should not be logged in this solution
- Encrypted secrets are logged in this solution, however they should only be able to be decrypted by the intended recipient
## Caveats
- I don't want to create a bunch of tedious GPG keys, so am using the "userone" GPG key for everyone.  In a real setup (as per description above,) each user has their own GPG key.
- All of the listed EKS clusters are fake ARNs and not in valid accounts.

## Future Improvements
- Instead of managing secret access keys with GPG encryption, these could be managed by a more centralized solution like Vault or AWS Secrets Manager, or more federated solutions like Okta, etc.
- Federate users using something like Okta, and use short-lived access keys
- Configure and setup tfsec as a pipeline stage - https://aquasecurity.github.io/tfsec/v1.28.1/
- Add auto documentation of this module with terraform-docs - https://terraform-docs.io/user-guide/configuration/
- Enumerate explicit permissions for the Jenkins build agent: https://developer.hashicorp.com/terraform/language/settings/backends/s3 + limited IAM to manage these specific teams.  (Principal of least access.)
- Require specific approvers in the Jenkinsfile rather than just anyone
- Tests that IAM Groups and users are working correctly
- Dashboards into Jenkins build times, successes, and other operational information
- The backend engineering team will likely eventually need access to Route53 and ACM, for out-of-band work
- More teams will likely want a read-only view into all infrastructure, beyond what they manage directly
- Move user lists / GPG keys out to make it easier to manage.
- Use a secrets manager like Vault, AWS Secrets Manager, etc.
- Possibly modularize the terraform.  Current design keeps all related configuration for a team in the same file, but this could become overwhelming and difficult to read as it becomes more complicated.
- Possibly leverage IAM paths for organization.
- Data / variable validations
- Unit tests with hashicorp sentinel or something
- Possibly do multi-branch pipelines and support multiple devs
- Possibly deploy dev and stage in parallel
