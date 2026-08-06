# 목표
- CI Workflow 구성
  ```
    # 소스 변경 => push => GitHub Actions => 이미지 생성 => 임시인증(OIDC) => ECR 업데이트
    # 최초 1회 인프라 구성(테라폼) => 변경시 반영됨
    devops_tf_k8s_ci -> GitHub Actions -> AWS ECR
  ```