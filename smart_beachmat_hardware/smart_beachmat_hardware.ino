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

/* TODO:
 * - remove `print...` functions.
 */

// Bluetooth
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// UV sensing
#include <Wire.h>
#include "Adafruit_SI1145.h"

// BLE service UUIDs (https://www.bluetooth.com/specifications/gatt/services)
#define ENVIRONMENTAL_SENSING_SERVICE_UUID "181A"
#define BATTERY_SERVICE_UUID               "180F"

// BLE characteristic UUIDs (https://www.bluetooth.com/specifications/gatt/characteristics)
#define UV_INDEX_CHARACTERISTIC_UUID      "2A76"
#define BATTERY_LEVEL_CHARACTERISTIC_UUID "2A19"

// Time periods
#define NOTIFICATION_PERIOD 5000


BLEServer* pServer;
BLECharacteristic* uvIndexCharacteristic;
BLECharacteristic* batteryLevelCharacteristic;
BLEAdvertising* deviceAdvertising;

Adafruit_SI1145 sensor;

bool isConnected = false;

/*
 * Callbacks associated with the operation of a `BLEServer`.
 */
class ServerCallbacks: public BLEServerCallbacks {
  /*
   * Handle a new client connection.
   */
  void onConnect(BLEServer* pServer) {
    isConnected = true;
    Serial.println("Device connected.");
  }

  /*
   * Handle an existing client disconnection.
   */
  void onDisconnect(BLEServer* pServer) {
    isConnected = false;
    Serial.println("Device disconnected.");
  }
};

/*
 * Run once, after each powerup or reset of the device.
 */
void setup() {
  Serial.begin(115200);
  
  // Check for UV sensor.
  sensor = Adafruit_SI1145();
  while (!sensor.begin());
  Serial.println("UV sensor detected.");

  // Create the BLE device.
  BLEDevice::init("Smart Beach Mat");

  // Create the BLE server.
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  // Create the BLE environmental sensing service.
  BLEService* environmentalSensingService = pServer->createService(ENVIRONMENTAL_SENSING_SERVICE_UUID);

  // Create the BLE UV index characteristic.
  uvIndexCharacteristic = environmentalSensingService->createCharacteristic(
                            UV_INDEX_CHARACTERISTIC_UUID,
                            BLECharacteristic::PROPERTY_NOTIFY
                          );

  // Start the environmental sensing service.
  environmentalSensingService->start();

  // Create the BLE battery service.
  BLEService* batteryService = pServer->createService(BATTERY_SERVICE_UUID);

  // Create the BLE battery level characteristic.
  batteryLevelCharacteristic = batteryService->createCharacteristic(
                            BATTERY_LEVEL_CHARACTERISTIC_UUID,
                            BLECharacteristic::PROPERTY_NOTIFY
                          );

  // Start the battery service.
  batteryService->start();

  // Set up advertisement.
  deviceAdvertising = BLEDevice::getAdvertising();
  deviceAdvertising->setScanResponse(false);
  deviceAdvertising->addServiceUUID(ENVIRONMENTAL_SENSING_SERVICE_UUID);
  deviceAdvertising->addServiceUUID(BATTERY_SERVICE_UUID);
  deviceAdvertising->start();
}

/*
 * Loop continuously while the device is powered on.
 */
void loop() {
  // Notify connected device of UV index.
  if (isConnected) {
    float uvIndex = sensor.readUV() / 100.0;
    int batteryLevel = 40;

    Serial.print("UV: ");  Serial.println(uvIndex);
    Serial.print("BATTERY: ");  Serial.println(batteryLevel);
    
    uvIndexCharacteristic->setValue(uvIndex);
    uvIndexCharacteristic->notify();

    batteryLevelCharacteristic->setValue(batteryLevel);
    batteryLevelCharacteristic->notify();
    
    delay(NOTIFICATION_PERIOD);
  }
}
