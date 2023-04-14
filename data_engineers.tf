data "local_file" "data_engineer_gpg_public_keys" {
  for_each = {
    for index, engineer in local.data_engineers:
    engineer.username => engineer
  }
  filename = each.value.gpg_pub_key
}

resource "aws_iam_user" "data_engineers" {
  for_each = {
    for index, engineer in local.data_engineers:
    engineer.username => engineer
  }
  name = each.value.username
  path = "/"
  force_destroy = true
}

resource "aws_iam_access_key" "data_engineers" {
  depends_on = [
    aws_iam_user.data_engineers
  ]
  for_each = {
    for index, engineer in local.data_engineers:
    engineer.username => engineer
  }
  user = each.value.username
  pgp_key = data.local_file.data_engineer_gpg_public_keys[each.key].content
}

resource "aws_iam_group" "data_engineering" {
  name = "data_engineering"
  path = "/"
}

resource "aws_iam_group_membership" "data_engineers" {
  name = "data_engineers"
  users = [for user in aws_iam_user.data_engineers : user.name]
  group = aws_iam_group.data_engineering.name
}

resource "aws_iam_group_policy_attachment" "attach_redshift_policy" {
  group = aws_iam_group.data_engineering.name
  policy_arn = data.aws_iam_policy.AmazonRedshiftFullAccess.arn
}
