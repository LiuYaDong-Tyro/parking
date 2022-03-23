from datetime import datetime
import decimal
if __name__ == '__main__':
    car_in_time = int(1648023831)
    print(datetime.fromtimestamp(car_in_time))

    unit_price = decimal.Decimal('0.05')
    cost = unit_price * decimal.Decimal('100.1')
    print(decimal.Decimal(cost))
    print(cost/60)

    decimal.getcontext().prec = 3
    print(round(1/ 3))

