#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define BUTTON_PIN 2  // GPIO pin for the button
#define LED_PIN 4     // GPIO pin for the LED
int brightness = 0;  // how bright the LED is
int fadeAmount = 5;  // how many points to fade the LED by

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;

bool deviceConnected = false;
bool oldButtonState = HIGH; // Assume button is not pressed initially
bool ledState = LOW;        // Initial state of the LED (off)
int button_presses = 0;

// UUIDs for the service and characteristic
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Device connected!");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("Device disconnected!");
      // Restart advertising after disconnection
      BLEDevice::startAdvertising();
      Serial.println("Restarted BLE advertising...");
    }
};

class MyCharacteristicCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String value = pCharacteristic->getValue(); // Get the data written by the Flutter app

      if (value.length() > 0) {
        Serial.print("Received data: ");
        for (int i = 0; i < value.length(); i++) {
          Serial.print((char)value[i]);
        }
        Serial.println();

        // Check if the received message is "Toggle LED"
        if (value == "Toggle LED") {
          ledState = !ledState; // Toggle the LED state
          digitalWrite(LED_PIN, ledState); // Update the LED pin
          Serial.println(ledState ? "LED turned ON" : "LED turned OFF");
        } else {
          Serial.println("Unknown command received.");
        }
      }
    }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Initializing BLE...");

  // Configure the button pin as input with pull-up resistor
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Configure the LED pin as output
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, ledState); // Set initial LED state

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

void loop() {
  // Read the button state
  bool buttonState = digitalRead(BUTTON_PIN);

  // If the button is pressed and was not pressed before
  if (buttonState == LOW && oldButtonState == HIGH) {
    Serial.println("Button pressed!");
    if (deviceConnected) {
      pCharacteristic->setValue("Button Pressed!");
      pCharacteristic->notify();
      Serial.println("Notification sent: Button Pressed!");
    }
  }

  // Update the old button state
  oldButtonState = buttonState;

  delay(10); // Small delay to debounce the button
}