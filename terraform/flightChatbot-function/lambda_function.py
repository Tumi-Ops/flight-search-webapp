import json

import boto3
from botocore.exceptions import ClientError
from google import genai

ssm_client = boto3.client("ssm")
MODEL_ID = "gemini-2.5-flash"
params = None


def lambda_handler(event, context):
    print(context)
    body = json.loads(event["body"])
    user_input = body["message"]

    if not user_input:
        return {"statusCode": 400, "body": json.dumps({"error": "Message is required"})}

    ai_creds = get_ai_secrets()
    client = genai.Client(api_key=ai_creds["GEMINI_AI_API_KEY"])

    try:
        response = client.models.generate_content(
            model=MODEL_ID,
            contents=user_input,
        )
        response_text = response.text
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"reply": response_text}),
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"reply": str(e)}),
        }


def get_ai_secrets():
    global params

    if params:
        return params

    try:
        response = ssm_client.get_parameters(
            Names=["GEMINI_AI_API_KEY"], WithDecryption=True
        )
    except ClientError as e:
        raise e

    params = {x["Name"].split("/")[-1]: x["Value"] for x in response["Parameters"]}
    return params
