workflow "Build and Push to ECR" {
  on = "push"
  resolves = ["GitHub Action for Docker"]
}

action "Filters for GitHub Actions master" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch master"
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  args = "build -t $REGISTRY/simple-flask-app:latest ."
  env = {
    REGISTRY = "123094825799.dkr.ecr.us-west-2.amazonaws.com/test-github-actions"
  }
  needs = ["python-lint-master"]
}

action "python-lint-master" {
  uses = "CyberZHG/github-action-python-lint@master"
  needs = ["Filters for GitHub Actions master"]
}

workflow "New workflow" {
  on = "push"
  resolves = ["python-lint-dev"]
}

action "python-lint-dev" {
  uses = "CyberZHG/github-action-python-lint@master"
  needs = ["Filters for GitHub Actions dev"]
}

action "Filters for GitHub Actions dev" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch dev"
}
