output "sitereliability_engineer_credentials" {
  value = [
    for username, user in aws_iam_user.sitereliability_engineers : {
      username                    = username
      aws_access_key_id           = aws_iam_access_key.sitereliability_engineers[username].id
      encrypted_secret_access_key = aws_iam_access_key.sitereliability_engineers[username].encrypted_secret
    }
  ]
}

output "frontend_engineer_credentials" {
  value = [
    for username, user in aws_iam_user.frontend_engineers : {
      username                    = username
      aws_access_key_id           = aws_iam_access_key.frontend_engineers[username].id
      encrypted_secret_access_key = aws_iam_access_key.frontend_engineers[username].encrypted_secret
    }
  ]
}

output "backend_engineer_credentials" {
  value = [
    for username, user in aws_iam_user.backend_engineers : {
      username                    = username
      aws_access_key_id           = aws_iam_access_key.backend_engineers[username].id
      encrypted_secret_access_key = aws_iam_access_key.backend_engineers[username].encrypted_secret
    }
  ]
}

output "data_engineer_credentials" {
  value = [
    for username, user in aws_iam_user.data_engineers : {
      username                    = username
      aws_access_key_id           = aws_iam_access_key.data_engineers[username].id
      encrypted_secret_access_key = aws_iam_access_key.data_engineers[username].encrypted_secret
    }
  ]
}
