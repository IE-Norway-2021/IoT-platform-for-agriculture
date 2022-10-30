# 1. IoT-platform-for-agriculture.

Jade Gröli & David González León

---

- [1. IoT-platform-for-agriculture.](#1-iot-platform-for-agriculture)
- [2. Architecture](#2-architecture)
- [3. Sensors](#3-sensors)
- [4. Development Steps](#4-development-steps)
  - [4.1. Plug and Sense](#41-plug-and-sense)
  - [4.2. The Thing Network](#42-the-thing-network)
  - [4.3. Azure](#43-azure)
    - [4.3.1. Azure functions](#431-azure-functions)
    - [4.3.2. InfluxDB Azure](#432-influxdb-azure)
    - [4.3.3. Azure Managed Graphana](#433-azure-managed-graphana)

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

### 4.3.2. InfluxDB Azure

### 4.3.3. Azure Managed Graphana
