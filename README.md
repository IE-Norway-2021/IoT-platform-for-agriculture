# IoT-platform-for-agriculture.

A project that creates a smart agriculture platform based on the Libelium Plug and sense

# Architecture

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

# Sensors

-   Temp, humidity, pressure : port F
-   Water sensor : port C
-   Soil temp : port D
