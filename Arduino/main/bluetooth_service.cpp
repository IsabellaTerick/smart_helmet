#include "bluetooth_service.h"

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;

bool deviceConnected = false;
String currentMode = "safe"; // Initial mode is safe

// Callbacks for BLE server events
class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Device connected!");

      // Send the current mode to the Flutter app after connection
      if (pCharacteristic != NULL) {
        delay(5000);
        pCharacteristic->setValue(currentMode.c_str());
        pCharacteristic->notify();
        Serial.print("Connection mode sent to app: ");
        Serial.println(currentMode);
      }
    }

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("Device disconnected!");
      BLEDevice::startAdvertising(); // Restart advertising after disconnection
      Serial.println("Restarted BLE advertising...");
    }
};

// Callbacks for BLE characteristic events
class MyCharacteristicCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String value = pCharacteristic->getValue(); // Get the data written by the Flutter app

      if (value.length() > 0) {
        String receivedValue(value.c_str());
        Serial.print("Received data: ");
        Serial.println(receivedValue);

        // Check if the received message is a mode update
        if (receivedValue == "safe" || receivedValue == "crash") {
          if (currentMode != receivedValue) {
            currentMode = receivedValue;
            Serial.print("Mode synchronized with app: ");
            Serial.println(currentMode);
          }
        } else {
          Serial.println("Unknown command received.");
        }
      }
    }
};

// Initialize the Bluetooth service
void setupBluetooth() {
  Serial.begin(115200);
  Serial.println("Initializing BLE...");

  // Initialize BLE
  BLEDevice::init("ESP32_BLE");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create the BLE characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );

  // Add a descriptor to the characteristic
  pCharacteristic->addDescriptor(new BLE2902());
  pCharacteristic->setCallbacks(new MyCharacteristicCallbacks()); // Set callbacks for write events
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // Functions that help with iPhone connections
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("BLE advertising started.");
}

// Handle notifications to the Flutter app
void handleBluetoothNotifications(String mode) {
  if (deviceConnected && pCharacteristic != NULL) {
    pCharacteristic->setValue(mode.c_str());
    pCharacteristic->notify();
    Serial.print("Notification sent: ");
    Serial.println(mode);
  }
}

// Check if a device is connected
bool isDeviceConnected() {
  return deviceConnected;
}