aws_region   = "ap-northeast-2"
project_name = "de-ai-25-eks-auto"
environment  = "dev"

kubernetes_version = "1.35"

# 운영 환경에서는 반드시 본인/회사 공인 IP만 허용
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

additional_admin_role_arns = []

# 비용을 더 낮추려면 Single-AZ로 변경할 수 있지만 현재는 v2와 동일한 Multi-AZ 효과를 유지
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20

# ------------------------------------------------------------
# GitHub Actions CI
# ------------------------------------------------------------
enable_github_actions_ci = true
github_owner             = ""
github_ci_repository     = ""
github_ci_branch         = ""
create_github_oidc_provider = true
# 조회발급
github_owner_id         = ""
github_ci_repository_id = ""