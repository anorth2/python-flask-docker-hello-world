import pulumi
from pulumi_kubernetes.apps.v1 import Deployment
from pulumi_kubernetes.core.v1 import Service

app_labels = {"app": "flask"}
image = "123094825799.dkr.ecr.us-west-2.amazonaws.com/test-github-actions/flask-test:latest"
flask_container = \
    {
        "name": "flask-app",
        "image": image,
        "ports":
            [{"containerPort": 8080}],
        "imagePullPolicy": "Always"
    }
ecr_pull_secret = \
    {
        "name": "regcred"
    }

spec = \
    {
        "containers":
            [flask_container],
        "imagePullSecrets":
            [ecr_pull_secret]
    }

deployment = Deployment(
    "flask",
    spec={
        "selector": {"match_labels": app_labels},
        "replicas": 1,
        "template": {
            "metadata": {"labels": app_labels},
            "spec": spec
        }
    })

frontend = Service(
    "flask",
    metadata={
        "labels": deployment.spec["template"]["metadata"]["labels"],
    },
    spec={
        "type": "LoadBalancer",
        "ports": [{"port": 80, "target_port": 80, "protocol": "TCP"}],
        "selector": app_labels,
    })

pulumi.export("name", deployment.metadata["name"])
