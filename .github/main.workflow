workflow "Build and Push to ECR" {
  resolves = [
    "actions/aws/cli@master",
    "Push release to ECR",
    "GitHub Action for Docker-3",
    "GitHub Action for Docker-4",
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
  args = "\"--max-line-length=120\""
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  needs = ["CyberZHG/github-action-python-lint@master"]
  args = "branch master"
}

action "Filters for GitHub Actions-1" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  needs = ["CyberZHG/github-action-python-lint@master"]
  args = "branch dev"
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Filters for GitHub Actions-1"]
  args = "build -t $IMAGE_NAME:dev ."
  secrets = ["IMAGE_NAME"]
}

action "GitHub Action for Docker-1" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Filters for GitHub Actions"]
  args = "build -t $IMAGE_NAME:latest ."
  secrets = ["IMAGE_NAME"]
}

action "GitHub Action for Docker-2" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Filters for GitHub Actions"]
  args = "build -t $IMAGE_NAME:release ."
  secrets = ["IMAGE_NAME"]
}

action "actions/aws/cli@master" {
  uses = "actions/aws/cli@master"
  needs = ["CyberZHG/github-action-python-lint@master"]
  args = "ecr get-login --no-include-email --region $AWS_DEFAULT_REGION | sh"
  env = {
    AWS_DEFAULT_REGION = "us-west-2"
  }
}

action "Push release to ECR" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["GitHub Action for Docker-2", "actions/aws/cli@master"]
  secrets = ["IMAGE_NAME"]
  args = "push $IMAGE_NAME:release"
}

action "GitHub Action for Docker-3" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["GitHub Action for Docker-1", "actions/aws/cli@master"]
  args = "push $IMAGE_NAME:latest"
  secrets = ["IMAGE_NAME"]
}

action "GitHub Action for Docker-4" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["GitHub Action for Docker", "actions/aws/cli@master"]
  args = "push $IMAGE_NAME:dev"
  secrets = ["IMAGE_NAME"]
}
