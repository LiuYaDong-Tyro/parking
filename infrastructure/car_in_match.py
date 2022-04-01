import os
import time

import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('parking')

client = boto3.client('sns')


def validate_current_count(limit_count):
    response = table.query(
        KeyConditionExpression=Key('car_state').eq("car_in")
    )
    items = response['Items']
    current_count = len(items)
    print("count is " + str(current_count))
    if current_count >= limit_count:
        return True
    else:
        return False


def save_to_db(car_no):
    table.put_item(
        Item={
            'car_state': 'car_in',
            'car_no': car_no,
            'time': int(time.time()),
        }
    )


def send_sns(message):
    print(message)
    client.publish(
        TopicArn='arn:aws:sns:ap-southeast-2:160071257600:car_info',
        Message=message,
    )


def validate_count(max_total_count, car_no):
    is_full = validate_current_count(max_total_count)
    if is_full:
        message = "The parking space is full, no parking space is available"
        send_sns(message)
        return message
    else:
        save_to_db(car_no)
        message = "welcome " + car_no + ", then open the door"
        send_sns(message)
        return message


def do_enter(event, context):
    print(os.environ)
    car_no = event['car_no']
    max_total_count = 100
    return validate_count(max_total_count, car_no)


def find_current_count(car_no):
    response = table.query(
        KeyConditionExpression=Key('car_no').eq(car_no) & Key('car_state').eq("car_in")
    )
    items = response['Items']
    print(items)
    print(table.item_count)




