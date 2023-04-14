resource "aws_iam_user" "sitereliability_engineers" {
  for_each = {
    for index, engineer in local.sitereliability_engineers:
    engineer.username => engineer
  }
  name = each.value.username
  path = "/"
  force_destroy = true
}

resource "aws_iam_group" "sitereliability_engineering" {
  name = "sitereliability_engineering"
  path = "/"
}

resource "aws_iam_access_key" "sitereliability_engineers" {
  for_each = {
    for index, engineer in local.sitereliability_engineers:
    engineer.username => engineer
  }
  user = each.value.username
  pgp_key = data.local_file.sitereliability_engineer_gpg_public_keys[each.key].content
}

resource "aws_iam_group_membership" "sitereliability_engineers" {
  name = "sitereliability_engineers"
  users = [for user in aws_iam_user.sitereliability_engineers : user.name]
  group = aws_iam_group.sitereliability_engineering.name
}

resource "aws_iam_group_policy_attachment" "attach_admin_policy" {
  group = aws_iam_group.sitereliability_engineering.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}
