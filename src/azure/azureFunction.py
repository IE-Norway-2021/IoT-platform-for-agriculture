# Azure function to be deployed to Azure. Receives data from a http webhook and writes it to a InfluxDB database hosted in Azure

import logging
import json
import azure.functions as func
from influxdb import InfluxDBClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Get the data from the http request
    data = req.get_json()
    logging.info(data)

    # Create a client to connect to the InfluxDB database
    client = InfluxDBClient(host='localhost', port=8086, username='admin', password='admin', database='test')

    # Create the JSON data to be written to the database
    json_body = [
        {
            "measurement": "temperature",
            "tags": {
                "location": "office"
            },
            "fields": {
                "value": data['temperature']
            }
        }
    ]

    # Write the data to the database
    client.write_points(json_body)

    return func.HttpResponse("OK")