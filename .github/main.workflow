workflow "Build and Push to ECR" {
  on = "push"
  resolves = ["GitHub Action for Docker"]
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch master"
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["python-lint"]
  args = "build -t $REGISTRY/simple-flask-app:latest ."
  env = {
    REGISTRY = "123094825799.dkr.ecr.us-west-2.amazonaws.com/test-github-actions"
  }
}

action "python-lint" {
  uses = "CyberZHG/github-action-python-lint@master"
  needs = ["Filters for GitHub Actions"]
}
