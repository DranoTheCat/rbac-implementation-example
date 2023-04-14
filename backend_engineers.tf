data "local_file" "backend_engineer_gpg_public_keys" {
  for_each = {
    for index, engineer in local.backend_engineers:
    engineer.username => engineer
  }
  filename = each.value.gpg_pub_key
}

resource "aws_iam_user" "backend_engineers" {
  for_each = {
    for index, engineer in local.backend_engineers:
    engineer.username => engineer
  }
  name = each.value.username
  path = "/"
  force_destroy = true
}

resource "aws_iam_access_key" "backend_engineers" {
  depends_on = [
    aws_iam_user.backend_engineers
  ]
  for_each = {
    for index, engineer in local.backend_engineers:
    engineer.username => engineer
  }
  user = each.value.username
  pgp_key = data.local_file.backend_engineer_gpg_public_keys[each.key].content
}

resource "aws_iam_policy" "eks_full_access" {
  name        = "eks_full_access"
  path        = "/"
  description = "Full access to EKS clusters"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:*"
        ]
        Effect   = "Allow"
        Resource = var.eks_backend_allowed_arns
      },
    ]
  })
}

resource "aws_iam_group" "backend_engineering" {
  name = "backend_engineering"
  path = "/"
}

resource "aws_iam_group_membership" "backend_engineers" {
  name = "backend_engineers"
  users = [for user in aws_iam_user.backend_engineers : user.name]
  group = aws_iam_group.backend_engineering.name
}

resource "aws_iam_group_policy_attachment" "attach_eks_policy" {
  group = aws_iam_group.backend_engineering.name
  policy_arn = aws_iam_policy.eks_full_access.arn
}
