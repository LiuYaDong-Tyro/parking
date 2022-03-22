import os

import boto3


def do_enter(event, context):
    print(os.environ)
    find_current_count()
    # find in db count
    current_total_count = 1
    max_total_count = 100
    if current_total_count >= max_total_count:
        return "The parking space is full, no parking space is available"
    else:
        car_no = event['car_no']
        return "welcome " + car_no + ", then open the door"


def find_current_count():
    # Get the service resource.
    dynamodb = boto3.resource('dynamodb')

    # Create the DynamoDB table.
    table = dynamodb.create_table(
        TableName='users',
        KeySchema=[
            {
                'AttributeName': 'username',
                'KeyType': 'HASH'
            },
            {
                'AttributeName': 'last_name',
                'KeyType': 'RANGE'
            }
        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'username',
                'AttributeType': 'S'
            },
            {
                'AttributeName': 'last_name',
                'AttributeType': 'S'
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,
            'WriteCapacityUnits': 5
        }
    )


    # Wait until the table exists.
    table.wait_until_exists()


    table.put_item(
        Item={
            'username': 'janedoe',
            'first_name': 'Jane',
            'last_name': 'Doe',
            'age': 25,
            'account_type': 'standard_user',
        }
    )

    # Print out some data about the table.
    print(table.item_count)




