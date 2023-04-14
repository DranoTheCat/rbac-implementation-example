# Example AWS RBAC Implementation in Terraform

An example RBAC implementation for an online service

## Important Links

## Instructions on how to Add a new user
1. A Base64 of the user's private GPG keypair is required.  This can be generated in any method desired; for example, install GnuPG and run:
    gpg --full-generate-key
    gpg --list-keys
    gpg --export 989296EB978E333BC8D6E8724876D98BA451E7FF |base64
2. Create a file under the folder public_gpg_keys named user.gpg.  Paste the base64 of the user's private GPG keypair here.
3. Add a user stanza for the user in main.tf, in the appropriate team location
4. Commit the change in a new branch, and submit a PR.  Once approved and merged into main, automation should kick off the Jenkins pipeline.
5. Once the pipeline has finished and changes have been applied, review the Jenkins build, click on the environment for the relevant stage (e.g., dev, stage, or prod), and click on the green Logs button.  Expand the "terraform apply" command subsection, and scroll through the outputs until you find the user credentials you are looking for.  Since the secret access key is encrypted, only the user should be able to decrypt, and so the information should be safe to send, or safe to have the user self-service retrieve.
6. If permitted, this entire process could be self-serviced by the end-user.  They add themselves to the appropriate group via the steps above, submit a PR to be approved, and once merged in, they could retrieve their access key and secret.

An example commit to add "example user" to frontend_engineers can be found here:  https://github.com/DranoTheCat/rbac-implementation-example/commit/9a5c6de44d2cf860dd0c6d27585351d3ae799354

This is a fairly ugly and dirty approach to self-service, but it gets the job done in the time constraint.

## Instructions on how to Remove an existing user
1. Remove the user's GPG key file.
2. Remove the user's stanza from main.tf
3. Commit the change in a new branch, and submit a PR.  Once approved and merged into main, automation should kick off the Jenkins pipeline.
4. The user should be removed after the pipeline finishes running.

## Design Overview

## Considerations
### General Considerations
- Users should ideally authenticate with keys, not passwords.  In either case, however, key exchange becomes a problem.
- There are usually existing solutions to this problem that could be leveraged, however, this solution must assume such a solution is not already in place.  In addition, there is a 2hr time limit, so I've chosen a simple approach of having each user create a GPG key pair and provide the public half of it.  This way the encrypted key can be stored in terraform state relatively safely, and displayed as an output.  The user can then self-service retrieving their own key as described above, and only they should be able to decrypt it.  This isn't an ideal method of distribution, but prevents toil of needing an admin to provide the keys manually, and was achievable within the time limit.
### Cost Analysis
### Security
### Automation
### Monitoring
### Logging

## Caveats
- I don't want to create a bunch of tedious GPG keys, so am using the "userone" GPG key for everyone.  In a real setup (as per description above,) each user has their own GPG key.
- All of the listed EKS clusters are fake ARNs and not in valid accounts.

## Future Improvements
- Instead of managing secret access keys with GPG encryption, these could be managed by a more centralized solution like Vault or AWS Secrets Manager, or more federated solutions like Okta, etc.
- 