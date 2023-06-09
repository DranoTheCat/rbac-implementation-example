data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "CloudFrontFullAccess" {
  arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

data "aws_iam_policy" "AmazonRedshiftFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
