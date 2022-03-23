import os

import boto3
from boto3.dynamodb.conditions import Key, Attr
import time


def do_enter(event, context):
    print(os.environ)
    car_no = event['car_no']
    find_current_count(car_no)
    # find in db count
    current_total_count = 1
    max_total_count = 100
    if current_total_count >= max_total_count:
        return "The parking space is full, no parking space is available"
    else:
        return "welcome " + car_no + ", then open the door"


def find_current_count(car_no):
    # Get the service resource.
    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('parking')

    table.put_item(
        Item={
            'car_state': 'car_in',
            'car_no': '陕A-00001',
            'time': int(time.time()),
        }
    )


    response = table.query(
        KeyConditionExpression=Key('car_no').eq(car_no) & Key('car_state').eq("car_in")
    )
    items = response['Items']
    print(items)


    # Print out some data about the table.
    print(table.item_count)




