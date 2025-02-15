workflow "Build and Push to ECR" {
  resolves = [
    "Pulumi Deploy (Current Stack)",
    "Lint",
    "actions/gcloud/cli@dc2b6c3bc6efde1869a9d4c21fcad5c125d19b81",
  ]
  on = "push"
}

action "Filters for GitHub Actions master" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch master"
}

action "python-lint-dev" {
  uses = "CyberZHG/github-action-python-lint@master"
  needs = ["Filters for GitHub Actions dev"]
}

action "Filters for GitHub Actions dev" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch dev"
}

action "Lint" {
  uses = "CyberZHG/github-action-python-lint@master"
  args = "--max-line-length=120 ."
}

action "Filter master branch" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch master"
  needs = ["Lint"]
}

action "Build latest docker image" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  args = "build -t $IMAGE_NAME:latest ."
  secrets = ["IMAGE_NAME"]
  needs = ["Filter master branch"]
}

action "Build release docker image" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  args = "build -t $IMAGE_NAME:release ."
  secrets = ["IMAGE_NAME"]
  needs = ["Filter master branch"]
}

action "AWS Auth" {
  uses = "actions/aws/cli@master"
  args = "ecr get-login --no-include-email --region $AWS_DEFAULT_REGION | sh"
  env = {
    AWS_DEFAULT_REGION = "us-west-2"
  }
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  needs = ["Lint"]
}

action "Push release to ECR" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = [
    "AWS Auth",
    "Build release docker image",
  ]
  secrets = ["IMAGE_NAME"]
  args = "push $IMAGE_NAME:release"
}

action "Push latest to ECR" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = [
    "AWS Auth",
    "Build latest docker image",
  ]
  args = "push $IMAGE_NAME:latest"
  secrets = ["IMAGE_NAME"]
}

action "Login to Google Cloud" {
  uses = "actions/gcloud/auth@master"
  secrets = ["GCLOUD_AUTH"]
  needs = ["Lint"]
}

action "Setup kubernetes credentials" {
  uses = "actions/gcloud/cli@dc2b6c3bc6efde1869a9d4c21fcad5c125d19b81"
  args = "container clusters get-credentials test-github-actions --zone us-central1-a"
  needs = ["Set project for Google Cloud"]
  secrets = ["GCLOUD_AUTH"]
}

action "Set project for Google Cloud" {
  uses = "actions/gcloud/cli@dc2b6c3bc6efde1869a9d4c21fcad5c125d19b81"
  needs = ["Login to Google Cloud"]
  args = "config set project test-github-actions"
}

action "Pulumi Deploy (Current Stack)" {
  uses = "anorth2/actions@master"
  args = ["up"]
  env = {
    "PULUMI_CI" = "up"
  }
  secrets = [
    "PULUMI_ACCESS_TOKEN",
    "KUBECONFIG",
  ]
  needs = [
    "Push latest to ECR",
    "Push release to ECR",
    "Setup kubernetes credentials",
    "actions/gcloud/cli@dc2b6c3bc6efde1869a9d4c21fcad5c125d19b81",
  ]
}

action "actions/gcloud/cli@dc2b6c3bc6efde1869a9d4c21fcad5c125d19b81" {
  uses = "actions/gcloud/cli@dc2b6c3bc6efde1869a9d4c21fcad5c125d19b81"
  needs = ["Set project for Google Cloud"]
  args = "container cluster get-credentials test-github-actions --zone us-central1-a"
  secrets = ["GCLOUD_AUTH"]
}
