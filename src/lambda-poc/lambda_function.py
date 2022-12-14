import os
import json


def handler(event, context):
    version = os.environ["APP_VERSION"]
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"Version ": version}),
    }
