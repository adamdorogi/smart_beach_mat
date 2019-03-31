/*************************************************** 
  This is a library for the Si1145 UV/IR/Visible Light Sensor

  Designed specifically to work with the Si1145 sensor in the
  adafruit shop
  ----> https://www.adafruit.com/products/1777

  These sensors use I2C to communicate, 2 pins are required to  
  interface
  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/
/*
    Video: https://www.youtube.com/watch?v=oCMOYS71NIU
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
    Ported to Arduino ESP32 by Evandro Copercini
    updated by chegewara

   Create a BLE server that, once we receive a connection, will send periodic notifications.
   The service advertises itself as: 4fafc201-1fb5-459e-8fcc-c5c9c331914b
   And has a characteristic of: beb5483e-36e1-4688-b7f5-ea07361b26a8

   The design of creating the BLE server is:
   1. Create a BLE Server
   2. Create a BLE Service
   3. Create a BLE Characteristic on the Service
   4. Start the service.
   5. Start advertising.

   A connect hander associated with the server starts a background task that performs notification
   every couple of seconds.
*/

// Bluetooth
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// UV
#include <Wire.h>
#include "Adafruit_SI1145.h"

// Service UUIDs (https://www.bluetooth.com/specifications/gatt/services)
#define ENVIRONMENTAL_SENSING_SERVICE_UUID "181A"
#define BATTERY_SERVICE_UUID               "180F"

// Characteristic UUIDs (https://www.bluetooth.com/specifications/gatt/characteristics)
#define UV_INDEX_CHARACTERISTIC_UUID      "2A76"
#define BATTERY_LEVEL_CHARACTERISTIC_UUID "2A19"

// Pins
#define LED_PIN    5
#define BUTTON_PIN 0


BLEServer* pServer = NULL;
BLECharacteristic* uvIndexCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
bool isAdvertising = false;
uint32_t value = 0;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      isAdvertising = false;
      Serial.println("Connected to device.");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("Disconnected from device.");
    }
};

Adafruit_SI1145 sensor = Adafruit_SI1145();

void setup() {
  // Set up LED.
  pinMode(LED_PIN, OUTPUT);
  
  Serial.begin(115200);

  // Check for UV sensor.
  if (!sensor.begin()) {
    Serial.println("Didn't find SI1145");
    while (!sensor.begin());
  }

  Serial.println("UV sensor detected.");

  // Create the BLE device.
  BLEDevice::init("Smart Beach Mat");

  // Create the BLE server.
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE service.
  BLEService* environmentalSensingService = pServer->createService(ENVIRONMENTAL_SENSING_SERVICE_UUID);

  // Create the BLE characteristic.
  uvIndexCharacteristic = environmentalSensingService->createCharacteristic(
                            UV_INDEX_CHARACTERISTIC_UUID,
                            BLECharacteristic::PROPERTY_READ   |
                            BLECharacteristic::PROPERTY_WRITE  |
                            BLECharacteristic::PROPERTY_NOTIFY |
                            BLECharacteristic::PROPERTY_INDICATE
                          );

  // Start the service.
  environmentalSensingService->start();
}

void startAdvertising() {
  // Create advertisement data.
  BLEAdvertisementData oAdvertisementData = BLEAdvertisementData();

  // Start advertising.
  BLEAdvertising* pAdvertising = pServer->getAdvertising();
  pAdvertising->setScanResponse(false);
  pAdvertising->setAdvertisementData(oAdvertisementData);
  pServer->startAdvertising();
  isAdvertising = true;
  Serial.println("Advertisement started.");
}

void loop() {
  // notify changed value
  if (deviceConnected) {
    Serial.println("===================");
    Serial.print("Vis: "); Serial.println(sensor.readVisible());
    Serial.print("IR: "); Serial.println(sensor.readIR());
    
    // Uncomment if you have an IR LED attached to LED pin!
    //Serial.print("Prox: "); Serial.println(sensor.readProx());
  
    float UVindex = sensor.readUV();
    // the index is multiplied by 100 so to get the
    // integer index, divide by 100!
    UVindex /= 100.0;  
    Serial.print("UV: ");  Serial.println(UVindex);
    
    uvIndexCharacteristic->setValue(UVindex);
    uvIndexCharacteristic->notify();
    delay(1000); // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
  }
  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    delay(500); // give the bluetooth stack the chance to get things ready
//    pServer->startAdvertising(); // restart advertising
//    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
    
  if (digitalRead(BUTTON_PIN) == LOW && !isAdvertising) {
    startAdvertising();
  }

  if (isAdvertising) {
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);
  }
}
