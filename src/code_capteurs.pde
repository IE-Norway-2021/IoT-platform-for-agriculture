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

char moteID[] = "A2";
bool error = 0;
uint8_t socket = SOCKET0;
char APP_KEY[] = "000102030405060708090A0B0C0D0E0F";
char APP_EUI[] = "000102030405060708090A0B0C0D0E0F";

void setup()
{
  // put your setup code here, to run once:
  USB.ON();

  error = LoRaWAN.factoryReset();
  error = LoRaWAN.setDataRate(5);
  error = LoRaWAN.setAppEUI(APP_EUI);
  error = LoRaWAN.setAppKey(APP_KEY);
  error = LoRaWAN.joinOTAA();
  error = LoRaWAN.OFF(socket);

  if (error == 0) {
    USB.println("No error");
  }

  frame.setID(moteID);

  Agriculture.ON();

}

float temp, humd, pres;
float soil_tmp, watermarkA, watermarkB, watermarkC, watermarkD, watermarkE, watermarkF;
pt1000Class pt1000Sensor;
watermarkClass wmSensorA(SOCKET_A);
watermarkClass wmSensorB(SOCKET_B);
watermarkClass wmSensorC(SOCKET_C);
watermarkClass wmSensorD(SOCKET_D);
watermarkClass wmSensorE(SOCKET_E);
watermarkClass wmSensorF(SOCKET_F);


void loop()
{
  // put your main code here, to run repeatedly:
  temp = Agriculture.getTemperature();
  humd = Agriculture.getHumidity();
  pres = Agriculture.getPressure();
  soil_tmp = pt1000Sensor.readPT1000();
  watermarkA = wmSensorA.readWatermark();
  watermarkB = wmSensorB.readWatermark();

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
  USB.printFloat(soil_tmp,3);
  USB.println(F(" Celsius"));
  USB.print(F("Watermark A - Frequency = "));
  USB.print(watermarkA);
  USB.println(F(" Hz"));
  USB.print(F("Watermark B - Frequency = "));
  USB.print(watermarkB);
  USB.println(F(" Hz"));
  USB.println(F("Watermark C - Frequency = "));
  USB.print(watermarkC);
  USB.println(F(" Hz"));
  USB.println(F("Watermark D - Frequency = "));
  USB.print(watermarkD);
  USB.println(F(" Hz"));
  USB.println(F("Watermark E - Frequency = "));
  USB.print(watermarkE);
  USB.println(F(" Hz"));
  USB.println(F("Watermark F - Frequency = "));
  USB.print(watermarkF);
  USB.println(F(" Hz"));
  

  delay(2000);

}
