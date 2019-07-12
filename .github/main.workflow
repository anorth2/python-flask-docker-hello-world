workflow "Build and Push to ECR" {
  resolves = [
    "Push release to ECR",
    "AWS Auth",
    "Push latest to ECR",
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

action "CyberZHG/github-action-python-lint@master" {
  uses = "CyberZHG/github-action-python-lint@master"
  args = "--max-line-length=120 ."
}

action "Filter master branch" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  needs = ["CyberZHG/github-action-python-lint@master"]
  args = "branch master"
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
  needs = ["CyberZHG/github-action-python-lint@master"]
  args = "ecr get-login --no-include-email --region $AWS_DEFAULT_REGION | sh"
  env = {
    AWS_DEFAULT_REGION = "us-west-2"
  }
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
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
