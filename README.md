# Example AWS RBAC Implementation in Terraform

An example RBAC implementation for an online service

## Overall Design

## Considerations
- Users should ideally authenticate with keys, not passwords.  In either case, however, key exchange becomes a problem.
- There are usually existing solutions to this problem that could be leveraged, however, this solution must assume such a solution is not already in place.  In addition, there is a 2hr time limit, so I've chosen a simple approach of having each user create a GPG key pair and provide the public half of it.  This way the encrypted key can be stored in terraform state relatively safely, and displayed as an output.  The user can then self-service retrieving their own key as described above, and only they should be able to decrypt it.

### 

## Caveats
- I don't want to create a bunch of tedious GPG keys, so am using the "userone" GPG key for everyone.  In a real setup (as per description above,) each user has their own GPG key.

## Future Improvements
- Instead of managing secret access keys with GPG encryption, these could be managed by a more centralized solution like Vault or AWS Secrets Manager, or more federated solutions like Okta, etc.
- 