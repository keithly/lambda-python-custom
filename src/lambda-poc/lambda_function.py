import sys


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/html"
        },
        "body": f"<h1>Hello World from custom runtime Python {sys.version}</h1><p>{event}</p>"
    }
