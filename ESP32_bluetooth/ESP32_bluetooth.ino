#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Pin definitions
const int BUTTON_PIN = 5; // GPIO pin connected to the physical button
const int LED_PIN = 2;    // GPIO pin connected to the internal LED (or external LED)
int brightness = 0;  // how bright the LED is
int fadeAmount = 5;  // how many points to fade the LED by

// Define UUIDs for the BLE service and characteristic
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"         // Service UUID
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8" // Characteristic UUID

// Global variables
BLECharacteristic *pCharacteristic;
BLEServer *pServer;
bool ledState = false; // Tracks the state of the LED
bool buttonPressed = false; // Tracks whether the button was pressed

/**
 * Server Callbacks
 * These functions handle client connection and disconnection events.
 */
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    Serial.println("Client connected");
  }

  void onDisconnect(BLEServer *pServer) {
    Serial.println("Client disconnected");
    pServer->startAdvertising(); // Restart advertising to allow reconnection
  }
};

/**
 * Characteristic Callbacks
 * These functions handle data written to the characteristic by the Flutter app.
 */
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue(); // Get the data written by the Flutter app

    if (value.length() > 0) {
      Serial.print("Received data: ");
      Serial.println(value); // Print the received data

      // Handle the "TOGGLE_LED" command
      if (value == "TOGGLE_LED") {
        ledState = !ledState; // Toggle the LED state
        digitalWrite(LED_PIN, ledState ? HIGH : LOW); // Update the LED
        Serial.println(ledState ? "LED turned ON" : "LED turned OFF");

        // Optionally, send a response back to the Flutter app
        pCharacteristic->setValue(ledState ? "LED_ON" : "LED_OFF");
        pCharacteristic->notify();
      }
    }
  }
};

/**
 * Setup Function
 * Initializes the ESP32, sets up BLE, and configures pins.
 */
void setup() {
  // Initialize serial communication for debugging
  Serial.begin(115200);

  // Configure pins
  pinMode(BUTTON_PIN, INPUT_PULLUP); // Use internal pull-up resistor for the button
  pinMode(LED_PIN, OUTPUT);          // Set the LED pin as output
  digitalWrite(LED_PIN, LOW);        // Turn off the LED initially

  // Initialize BLE
  BLEDevice::init("ESP32_BLE"); // Name of the BLE device
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks()); // Set server callbacks

  // Create a BLE service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE characteristic
  pCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ |   // Allow reading the characteristic
          BLECharacteristic::PROPERTY_WRITE | // Allow writing to the characteristic
          BLECharacteristic::PROPERTY_NOTIFY); // Allow sending notifications

  pCharacteristic->addDescriptor(new BLE2902()); // Add a descriptor for the characteristic
  pCharacteristic->setCallbacks(new MyCallbacks()); // Set characteristic callbacks

  // Start the service
  pService->start();

  // Start advertising the BLE server
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();

  Serial.println("BLE server started and advertising...");
}

/**
 * Loop Function
 * Continuously checks for button presses and sends notifications to the Flutter app.
 */
void loop() {
  // Check if the physical button is pressed
  if (digitalRead(BUTTON_PIN) == LOW) { // Button pressed (LOW because of pull-up resistor)
    if (!buttonPressed) { // Debounce: Ensure we only trigger once per press
      buttonPressed = true;

      // Notify the Flutter app that the button was pressed
      pCharacteristic->setValue("BUTTON_PRESSED");
      pCharacteristic->notify();
      Serial.println("Button pressed, notification sent to Flutter app.");
    }
  } else {
    buttonPressed = false; // Reset the button state when released
  }

  // Add a small delay to avoid excessive CPU usage
  delay(10);
}