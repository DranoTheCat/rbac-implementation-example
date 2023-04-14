data "local_file" "frontend_engineer_gpg_public_keys" {
  for_each = {
    for index, engineer in local.frontend_engineers:
    engineer.username => engineer
  }
  filename = each.value.gpg_pub_key
}

resource "aws_iam_user" "frontend_engineers" {
  for_each = {
    for index, engineer in local.frontend_engineers:
    engineer.username => engineer
  }
  name = each.value.username
  path = "/"
  force_destroy = true
}

resource "aws_iam_access_key" "frontend_engineers" {
  for_each = {
    for index, engineer in local.frontend_engineers:
    engineer.username => engineer
  }
  user = each.value.username
  pgp_key = data.local_file.frontend_engineer_gpg_public_keys[each.key].content
}

resource "aws_iam_group" "frontend_engineering" {
  name = "frontend_engineering"
  path = "/"
}

resource "aws_iam_group_membership" "frontend_engineers" {
  name = "frontend_engineers"
  users = [for user in aws_iam_user.frontend_engineers : user.name]
  group = aws_iam_group.frontend_engineering.name
}

resource "aws_iam_group_policy_attachment" "attach_cloudfront_policy" {
  group = aws_iam_group.frontend_engineering.name
  policy_arn = data.aws_iam_policy.CloudFrontFullAccess.arn
}
