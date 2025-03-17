#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define BUTTON_PIN 2  // GPIO pin for the button
#define LED_PIN 4     // GPIO pin for the LED
#define BT_STATUS_PIN 5 // GPIO pin to indicate Bluetooth connection status

// UUIDs for the service and characteristic
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;

bool deviceConnected = false;
bool oldButtonState = LOW; // Assume button is not pressed initially
String currentMode = "safe"; // Initial mode is safe
bool ledState = LOW;         // Initial state of the LED (off)

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      digitalWrite(BT_STATUS_PIN, HIGH); // Set pin 5 high when connected
      Serial.println("Device connected!");

      // Send the current mode to the Flutter app after connection
      if (pCharacteristic != NULL) {
        pCharacteristic->setValue(currentMode.c_str());
        pCharacteristic->notify();
        Serial.print("Connection mode sent to app: ");
        Serial.println(currentMode);
      }
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      digitalWrite(BT_STATUS_PIN, LOW); // Set pin 5 low when disconnected
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
        String receivedValue(value.c_str());
        Serial.print("Received data: ");
        Serial.println(receivedValue);

        // Check if the received message is a mode update
        if (receivedValue == "safe" || receivedValue == "crash") {
          if (currentMode != receivedValue) {
            // Synchronize mode with the Flutter app
            currentMode = receivedValue;
            Serial.print("Mode synchronized with app: ");
            Serial.println(currentMode);

            // Update the LED state based on the new mode
            ledState = (currentMode == "crash") ? HIGH : LOW;
            digitalWrite(LED_PIN, ledState);
            Serial.println(ledState ? "LED turned ON (Crash Mode)" : "LED turned OFF (Safe Mode)");
          }
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

  // Configure the Bluetooth status pin as output
  pinMode(BT_STATUS_PIN, OUTPUT);
  digitalWrite(BT_STATUS_PIN, LOW); // Initially set pin 5 low (disconnected)

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
    Serial.println(buttonState == LOW ? "Button state is low" : "Old button state was high");
    Serial.println("Button pressed!");

    // Toggle the mode
    currentMode = (currentMode == "safe") ? "crash" : "safe";
    Serial.print("Mode toggled to: ");
    Serial.println(currentMode);

    // Update the LED state based on the new mode
    ledState = (currentMode == "crash") ? HIGH : LOW;
    digitalWrite(LED_PIN, ledState);
    Serial.println(ledState ? "LED turned ON (Crash Mode)" : "LED turned OFF (Safe Mode)");

    // Notify the Flutter app about the new mode
    if (deviceConnected && pCharacteristic != NULL) {
      pCharacteristic->setValue(currentMode.c_str());
      pCharacteristic->notify();
      Serial.print("Notification sent: ");
      Serial.println(currentMode);
    }
  }

  // Update the old button state
  oldButtonState = buttonState;

  delay(10); // Small delay to debounce the button
}