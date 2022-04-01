import time
from datetime import datetime
import boto3
from boto3.dynamodb.conditions import Key
import decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('parking')

client = boto3.client('sns')


def do_calculate(event, context):
    car_no = event['car_no']
    response = table.query(
        KeyConditionExpression=Key('car_no').eq(car_no) & Key('car_state').eq("car_in")
    )
    items = response['Items']
    if len(items) > 1:
        return "system error"
    else:
        unit_price = 0.05
        print("unit price is " + str(unit_price))
        car_in_time = int(items[0]['time'])
        print("car_in_time is " + str(car_in_time))
        car_out_time = int(time.time())
        print("car_out_time is " + str(car_out_time))
        cost_time = car_out_time - car_in_time
        time_mins = round(cost_time / 60)
        print("cost time is " + str(time_mins) + "mins")
        cost_fee = time_mins * unit_price
        print("cost fee is " + str(cost_fee))
        save_to_db(car_no, car_out_time)
        car_in = datetime.fromtimestamp(car_in_time)
        car_out = datetime.fromtimestamp(car_out_time)
        fee = str(cost_fee)
        message = "car in time: " + str(car_in) + ";car out time is " \
               + str(car_out) + ";cost fee is " + fee
        send_sns(message)


def send_sns(message):
    print(message)
    client.publish(
        TopicArn='arn:aws:sns:ap-southeast-2:160071257600:car_info',
        Message=message,
    )


def save_to_db(car_no, car_out_time):
    table.put_item(
        Item={
            'car_state': 'car_out',
            'car_no': car_no,
            'time': car_out_time,
        }
    )
