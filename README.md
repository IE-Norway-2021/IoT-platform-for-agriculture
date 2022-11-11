# 1. IoT-platform-for-agriculture.

Jade Gröli & David González León

---

- [1. IoT-platform-for-agriculture.](#1-iot-platform-for-agriculture)
- [2. Architecture](#2-architecture)
- [3. Sensors](#3-sensors)
- [4. Development Steps](#4-development-steps)
  - [4.1. Plug and Sense](#41-plug-and-sense)
    - [4.1.1. Documentation](#411-documentation)
  - [4.2. The Thing Network](#42-the-thing-network)
  - [4.3. Azure](#43-azure)
    - [4.3.1. Azure functions](#431-azure-functions)
    - [4.3.2. InfluxDB Azure](#432-influxdb-azure)
    - [4.3.3. Azure Managed Graphana](#433-azure-managed-graphana)
    - [4.3.4. Deploying all components to Azure](#434-deploying-all-components-to-azure)

A project that creates a smart agriculture platform based on the Libelium Plug and sense

# 2. Architecture

-   Module Plug & Sense
    -   Récupère les données des capteurs
    -   Envoie packets à The Thing Network à travers LoRaWAN
-   The thing Network
    -   Formate les packets reçus avec CayenneLPP (à vérifier)
    -   Envoie à Azure functions à travers Webhook
-   Azure
    -   Azure functions
        -   Récupère les données de The Thing Network
        -   Effectue les insertions dans la base de donnée InfluxDB
    -   InfluxDB Azure
        -   Hébergé sur Azure
        -   Récupère les données envoyées par Azure functions et les mets à disposition de Grafana
    -   Azure Managed Graphana
        -   Récupère les données de InfluxDB Azure
        -   Affiche les données de chaque Module Plug & Sense

# 3. Sensors

-   Temp, humidity, pressure : port F
-   Water sensor : port C
-   Soil temp : port D

# 4. Development Steps

## 4.1. Plug and Sense

Create the code for the Plug and Sense module to gather data from the sensors and send them to The Thing Network.

### 4.1.1. Documentation

Code example : https://development.libelium.com/plug-and-sense/code-examples

Sensors sockets map : https://development.libelium.com/plug-and-sense-technical-guide/models

## 4.2. The Thing Network

At first we need to create the application and link the device to it

-   Add the gateway to The Thing Network to monitor incoming packets
-   Create a new application on The Thing Network
-   Create an end device for our mote, and generate :
    -   Device EUI
    -   Application EUI
    -   Application Key
-   Add the three values to the code for the Plug and Sense module
-   Select LoRaWAN version 1.0.0

Once this is done, we receive the messages from the Plug and Sense module on The Thing Network. We now need to decode them. We setup a payload formatter function using a custom javascript function. This allows us to decode the messages and format them in a way that is easier to read and manipulate.

## 4.3. Azure

### 4.3.1. Azure functions

We created a function in Azure that receives the payloads from The Thing Network through a http trigger we and inserts the data into the InfluxDB database. The function is written in python using version 3.9. We first developed the function locally and tested it on a local InfluxDB database. Once we were sure it worked, we deployed it to Azure.

### 4.3.2. InfluxDB Azure

To test the function, we used a local InfluxDB database. We used the following docker command to start the database :

```bash
docker run -d -p 8086:8086 --name influxdb -v influxdb:/var/lib/influxdb influxdb
```

Once the database was running, we set up the database and created a bucket for our data. We then created a token to allow our function to write to the database. We then tested the function locally writing data in the following format :

```json
[
    {
        "measurement": "iot_data2",
        "fields": {
            "waspmote_id": 42,
            "watermark": 0.0,
            "humidity": -1000.0,
            "pressure": -1000.0,
            "temperatureAir": -1000.0,
            "temperatureSoil": 5684.82,
            "batteryLevel": 30.0,
            "messageNumber": 1.0
        }
    }
]
```

We then tested using the web interface of the database to check if the data was correctly inserted.

### 4.3.3. Azure Managed Graphana

Once the database was correctly configured, we started working on the Grafana dashboard. We created a new Grafana instance using docker :

```bash
docker run -d -p 3000:3000 --name graphana grafana/grafana-enterprise
```

To allow Grafana to connect to the influxdb container, we had to create a network for both instances :

```bash
docker network create mynet
docker network connect mynet influxdb
docker network connect mynet graphana
```

We then added the influxdb datasource to the Grafana instance. We used the following configuration :

![Graphana datasource configuration](./img/grafana_config_1.jpg)

![Graphana datasource configuration](./img/grafana_config_2.jpg)

We had to specifically set the url to the name of the container, as the default "localhost" url was not working.

Once the datasource was configured, we created a new database and started adding panels. We added the following panels :

-   A panel to display the battery level of the mote
-   A panel to display the temperature of the air and the temperature of the soil
-   A panel to display the humidity
-   A panel to display the pressure
-   A panel to display the watermark

For each panel we queried the data using the following query :

```flux
from(bucket: "iot_bucket")
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "measures_agribots" and
    r._field == "batteryLevel"
  )
```

We adapted the query to get the correct field depending on the panel.

Once all the panels were created, we saved the dashboard and exported it to a json file so that we could easily import it in the future.

### 4.3.4. Deploying all components to Azure

-   Influx DB : container déployé sur Azure (les autres options marchent pas pour nous)
