import boto3
import logging
import json
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

route53 = boto3.client('route53')
ec2 = boto3.client('ec2')

HOSTED_ZONE_ID = os.environ['HOSTED_ZONE_ID']
RECORD_NAME = os.environ['RECORD_NAME']

def get_instance_ip(instance_id):
    """Retrieve the private IP of the EC2 instance."""
    try:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        return response['Reservations'][0]['Instances'][0]['PrivateIpAddress']
    except Exception as e:
        logger.error(f"Error fetching IP for instance {instance_id}: {e}")
        return None

def update_route53(action, ip_address, instance_id):
    """Update Route 53 DNS records."""
    try:
        r53_action = 'DELETE' if action == 'DELETE' else 'CREATE'
        response = route53.change_resource_record_sets(
            HostedZoneId=HOSTED_ZONE_ID,
            ChangeBatch={
                'Changes': [
                    {
                        'Action': r53_action,
                        'ResourceRecordSet': {
                            'Name': RECORD_NAME,
                            'Type': 'A',
                            'TTL': 60,
                            'ResourceRecords': [{'Value': ip_address}],
                            'SetIdentifier': instance_id
                        }
                    }
                ]
            }
        )
        logger.info(f"Route 53 update response: {response}")
    except Exception as e:
        logger.error(f"Error updating Route 53: {e}")

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    instance_id = sns_message.get('EC2InstanceId')
    state = sns_message.get('State')

    if state == 'running':
        ip_address = get_instance_ip(instance_id)
        if ip_address:
            update_route53('CREATE', ip_address, instance_id)
    elif state == 'terminated':
        update_route53('DELETE', '', instance_id)
