data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  github_actions_oidc_provider_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

  #github_actions_ci_subject = "repo:${var.github_owner}/${var.github_ci_repository}:ref:refs/heads/${var.github_ci_branch}"
  github_actions_ci_subject = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_ci_repository}@${var.github_ci_repository_id}:ref:refs/heads/${var.github_ci_branch}"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enable_github_actions_ci && var.create_github_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = {
    Name = "github-actions-oidc"
  }
}

data "aws_iam_policy_document" "github_actions_ci_assume" {
  count = var.enable_github_actions_ci ? 1 : 0

  statement {
    sid = "GitHubActionsAssumeRole"
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [local.github_actions_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [local.github_actions_ci_subject]
    }
  }
}


resource "aws_iam_role" "github_actions_ci" {
  count = var.enable_github_actions_ci ? 1 : 0

  name = "${local.cluster_name}-github-actions-ci-role"
  description = "GitHub Actions CI role for ECR image push"
  assume_role_policy = data.aws_iam_policy_document.github_actions_ci_assume[0].json
  max_session_duration = 3600
  depends_on = [aws_iam_openid_connect_provider.github_actions]
}

data "aws_iam_policy_document" "github_actions_ci" {
  count = var.enable_github_actions_ci ? 1 : 0

  statement {
    sid    = "ECRLogin"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushApplicationImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      aws_ecr_repository.web.arn,
      aws_ecr_repository.was.arn
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_ci" {
  count = var.enable_github_actions_ci ? 1 : 0
  name = "${local.cluster_name}-ecr-push-policy"
  role = aws_iam_role.github_actions_ci[0].id
  policy = data.aws_iam_policy_document.github_actions_ci[0].json
}
