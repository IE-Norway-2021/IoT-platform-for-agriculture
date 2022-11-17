#include <WaspSensorAmbient.h>

#include <WaspSensorAgr_v30.h>

#include <AgrXtrFrameConstants.h>
#include <CitiesProFrameConstants.h>
#include <WaspFrame.h>
#include <WaspFrameConstantsv12.h>
#include <WaspFrameConstantsv15.h>
#include <WtrXtrFrameConstants.h>

/*
    ------ Waspmote Pro Code Example --------

    Explanation: This is the basic Code for Waspmote Pro

    Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Put your libraries here (#include ...)
#include <WaspLoRaWAN.h>
#include <WaspUSB.h>

char moteID[] = "42";

uint8_t socket = SOCKET0;

char DEVICE_EUI[]  = "70B3D57ED0056E9F";
char APP_EUI[] = "1702199819021998";
char APP_KEY[] = "7609D24626A9EBD095AF3C736E74263B";

uint8_t error;
uint8_t PORT = 3;



void setup() 
{
  // put your setup code here, to run once:
  USB.ON();

  error = LoRaWAN.ON(socket);
  error = LoRaWAN.factoryReset();
  error = LoRaWAN.setDataRate(5);
  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);
  error = LoRaWAN.setAppEUI(APP_EUI);
  error = LoRaWAN.setAppKey(APP_KEY);
  error = LoRaWAN.joinOTAA();
  error = LoRaWAN.saveConfig();
  error = LoRaWAN.OFF(socket);

  if (error == 0) {
    USB.println("No error");
  } else {
    USB.println("Error During setup");
  }

  frame.setID(moteID);

  Agriculture.ON();

  USB.println("Setup done, starting loop");
}

float temp, humd, pres, soil_temp, watermark;
pt1000Class pt1000Sensor;
watermarkClass wmSensor(SOCKET_C);


void loop()
{
  // Read Sensors value
  temp = Agriculture.getTemperature();
  humd = Agriculture.getHumidity();
  pres = Agriculture.getPressure();
  soil_temp = pt1000Sensor.readPT1000();
  watermark = wmSensor.readWatermark();

  // Print sensors value
  USB.print(F("Temperature = "));
  USB.print(temp);
  USB.println(F("C"));
  USB.print(F("Humidity = "));
  USB.print(humd);
  USB.println(F("%"));
  USB.print(F("Pressure = "));
  USB.print(pres);
  USB.println(F(" PA"));
  USB.print(F("Soil temp = "));
  USB.printFloat(soil_temp,3);
  USB.println(F(" Celsius"));
  USB.print(F("Watermark - Frequency = "));
  USB.print(watermark);
  USB.println(F(" Hz"));

  // Create a new frame
  USB.println(F("Creating a new frame"));

  // Create new frame ASCII
  frame.createFrame(ASCII);

  // set frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  frame.addSensor(SENSOR_AGR_SOIL1, watermark);
  frame.addSensor(SENSOR_AGR_SOILTC, soil_temp);
  frame.addSensor(SENSOR_AGR_TC, temp);
  frame.addSensor(SENSOR_AGR_HUM,humd);  
  frame.addSensor(SENSOR_AGR_PRES, pres);


  // Print frame
  frame.showFrame();


  // Switch on
  error = LoRaWAN.ON(socket);

  // Check status
  if (error != 0) {
    USB.print(F("Switch ON error = "));
    USB.println(error, DEC);
    PWR.reboot();
  }

  // Join network

  error = LoRaWAN.joinABP();


  // Check status
  if (error == 0) {
    USB.println(F("Join network OK"));

    // send un-confirmed packet
    error = LoRaWAN.sendUnconfirmed(PORT, frame.buffer, frame.length);


    if (error == 0) {
      USB.println(F("Send unconfirmed packet OK"));

      if (LoRaWAN._dataReceived == true) {
        USB.print(F("Data on port number"));
        USB.print(LoRaWAN._port, DEC);
        USB.print(F(".\r\n Data: "));
        USB.println(LoRaWAN._data);

      }

    } else {
      USB.print(F("Send unconfirmed packet error = "));
      USB.println(error, DEC);
      PWR.reboot();
    }
  } else {
    USB.print(F("Join network error = "));
    USB.println(error, DEC);
    PWR.reboot();
  }

  // Switch off
  error = LoRaWAN.OFF(socket);

  if (error != 0) {
    USB.print(F("Switch OFF error = "));
    USB.println(error, DEC);
    PWR.reboot();
  }


  delay(300000); // 5 minutes
}