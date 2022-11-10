import logging
import json

import azure.functions as func
from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import SYNCHRONOUS

TOKEN = "3mWZAnt8LKLrzGwIwJSVCb1jCGM872fgYWnI687Kb6fedGvMiCwAulnhOvkjR2k4RwCaL9ExoPEFtx2rFGtO9g=="
URL = "http://localhost:8086"
ORG = "iot_agriculture"
BUCKET = "iot_bucket"
MEASUREMENT = "measures_agribots"

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    waspMoteId = req.params.get('waspMoteId')
    watermark = req.params.get('watermark')
    batteryLevel = req.params.get('batteryLevel')
    humidity = req.params.get('humidity')
    messageNumber = req.params.get('messageNumber')
    pressure = req.params.get('pressure')
    temperatureAir = req.params.get('temperatureAir')
    temperatureSoil = req.params.get('temperatureSoil')
    # time = req.params.get('time')

    if not waspMoteId or not watermark or not batteryLevel or not humidity or not messageNumber or not pressure or not temperatureAir or not temperatureSoil:
        try:
            # get json body
            req_body = req.get_json()
            if type(req_body) is str:
                req_body = json.loads(req_body)
        except ValueError:
            pass
        else:
            waspMoteId = req_body.get('waspMoteId')
            watermark = req_body.get('watermark')
            batteryLevel = req_body.get('batteryLevel')
            humidity = req_body.get('humidity')
            messageNumber = req_body.get('messageNumber')
            pressure = req_body.get('pressure')
            temperatureAir = req_body.get('temperatureAir')
            temperatureSoil = req_body.get('temperatureSoil')
            # time = req_body.get('time')

    if waspMoteId and watermark and batteryLevel and humidity and messageNumber and pressure and temperatureAir and temperatureSoil:
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
