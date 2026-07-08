import json

def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from Lambda! 你好，来自 Lambda 的问候！"
        })
    }