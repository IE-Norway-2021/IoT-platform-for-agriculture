import logging
import json

import azure.functions as func
from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import SYNCHRONOUS

TOKEN = "INSERT YOUR TOKEN"
# URL :  "http://<ip>:<port>"
URL = "INSERT YOUR URL"
ORG = "iot_agriculture"
BUCKET = "iot_bucket"
MEASUREMENT = "measures_agribots"

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # logging.info(req.params)

    # data = req.params.get('data').get('uplink_message').get('decoded_payload')
    # logging.info(data)

    # waspMoteId = data.get('waspMoteId')
    # watermark = data.get('watermark')
    # batteryLevel = data.get('batteryLevel')
    # humidity = data.get('humidity')
    # messageNumber = data.get('messageNumber')
    # pressure = data.get('pressure')
    # temperatureAir = data.get('temperatureAir')
    # temperatureSoil = data.get('temperatureSoil')
    # # time = req.params.get('time')

    # if not waspMoteId or not watermark or not batteryLevel or not humidity or not messageNumber or not pressure or not temperatureAir or not temperatureSoil:
    try:
        # get json body
        req_body = req.get_json()
        logging.info(req_body)
        logging.info(type(req_body))
        if type(req_body) == dict:
            req_body = str(req_body)
        # replace all ' by "
        req_body = req_body.replace("'", '"')
        # replace None by "None"
        req_body = req_body.replace("None", '"None"')
        logging.info(req_body)
        if type(req_body) is str:
            req_body = json.loads(req_body)
        req_body = req_body.get('uplink_message').get('decoded_payload')
        logging.info(req_body)
    except ValueError:
        logging.info("Error: No JSON body found")
        pass
    else:
        if req_body:
            waspMoteId = req_body.get('waspMoteId')
            watermark = req_body.get('watermark')
            batteryLevel = req_body.get('batteryLevel')
            humidity = req_body.get('humidity')
            messageNumber = req_body.get('messageNumber')
            pressure = req_body.get('pressure')
            temperatureAir = req_body.get('temperatureAir')
            temperatureSoil = req_body.get('temperatureSoil')
            # time = req_body.get('time')

    if req_body and waspMoteId and watermark and batteryLevel and humidity and messageNumber and pressure and temperatureAir and temperatureSoil:
        # structure the new data to prepare the influxdb data insert
        data = [
            {
                "measurement": MEASUREMENT,
                "fields": {
                    "waspmote_id": int(waspMoteId),
                    "watermark": float(watermark),
                    "humidity": float(humidity),
                    "pressure": float(pressure),
                    "temperatureAir": float(temperatureAir),
                    "temperatureSoil": float(temperatureSoil),
                    "batteryLevel": float(batteryLevel),
                    "messageNumber": int(messageNumber)
                }
            }
        ]
        logging.info("data written to influxdb" + str(data))
        # connect to the influxdb
        client = InfluxDBClient(url=URL, token=TOKEN, org=ORG)
        write_api = client.write_api(write_options=SYNCHRONOUS)
        # write the data to the influxdb
        write_api.write(bucket=BUCKET, record=data)
        return func.HttpResponse(f"The data was successfully inserted into the database", status_code=200)
    else: # if the data is not complete
        return func.HttpResponse(
             "The data was not correct, so no write was done",
             status_code=400
        )
