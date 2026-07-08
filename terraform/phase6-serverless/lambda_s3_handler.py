import json

def handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        print(f"New object uploaded: s3://{bucket}/{key}")
    return {"statusCode": 200}