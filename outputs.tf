output "sitereliability_engineer_credentials" {
  value = [
    for username, user in aws_iam_user.sitereliability_engineers : {
      username                  = username
      aws_access_key_id         = aws_iam_access_key.sitereliability_engineers[username].id
      encrypted_secret_access_key = aws_iam_access_key.sitereliability_engineers[username].encrypted_secret
    }
  ]
}

output "frontend_engineer_credentials" {
  value = [
    for username, user in aws_iam_user.frontend_engineers : {
      username                  = username
      aws_access_key_id         = aws_iam_access_key.frontend_engineers[username].id
      encrypted_secret_access_key = aws_iam_access_key.frontend_engineers[username].encrypted_secret
    }
  ]
}
