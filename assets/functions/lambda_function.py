import json
import os
import boto3

SNS_TOPIC_ARN=os.getenv('SNS_TOPIC_ARN')

## Create the 
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    try:
        finding = event['detail']['findings'][0]
        finding_id = finding['Id']
        finding_description = finding['Description']
        finding_severity = finding['Severity']['Label']
        finding_account_name = finding['AwsAccountName']
        finding_generator = finding['GeneratorId']

        # Format the message to something more useful
        formatted_message = {
            'FindingId': finding_id,
            'Description': finding_description,
            'GeneratorId': finding_generator,
            'Severity': finding_severity,
            'AccountName': finding_account_name,
            'Resources': finding['Resources']
        }
        response = sns_client.publish(
            TopicArn = SNS_TOPIC_ARN,
            Message = json.dumps(formatted_message),
            Subject = 'Security Hub Finding'
        )

        print("SNS Response: " + json.dumps(response, indent=2))
    except Exception as e:
        print(f"Error processing event: {str(e)}")
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully forwarded on the message')
    }
