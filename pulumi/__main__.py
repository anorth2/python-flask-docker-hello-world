import pulumi
from pulumi_kubernetes.apps.v1 import Deployment

app_labels = {"app": "flask"}

deployment = Deployment(
    "flask",
    spec={
        "selector": {"match_labels": app_labels},
        "replicas": 1,
        "template": {
            "metadata": {"labels": app_labels},
            "spec": {
                "containers":
                    [
                        {
                            "name":
                                "flask-app",
                            "image":
                                "123094825799.dkr.ecr.us-west-2.amazonaws.com/test-github-actions/flask-test:latest",
                            "ports":
                                [
                                    {
                                        "containerPort": 8080
                                    }
                                ]

                        }
                    ]
            }
        }
    })

pulumi.export("name", deployment.metadata["name"])
