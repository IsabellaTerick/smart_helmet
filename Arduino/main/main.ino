#include "bluetooth_service.h"
#include "bluetooth_indicator.h"

#define BUTTON_PIN 2  // GPIO pin for the button
#define LED_PIN 4     // GPIO pin for the LED

bool oldButtonState = LOW; // Assume button is not pressed initially
extern String currentMode;  // Takes current mode from bluetooth_service
bool ledState = LOW;        // Initial state of the LED (off)

void setup() {
  // Configure pins
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, ledState); // Set initial LED state

  // Initialize Bluetooth and its indicator
  setupBluetooth();
  setupBluetoothIndicator();
}

void loop() {
  // Update the Bluetooth status indicator
  updateBluetoothIndicator(isDeviceConnected());

  // Read the button state
  bool buttonState = digitalRead(BUTTON_PIN);

  // Toggle the mode if the button is pressed
  if (buttonState == LOW && oldButtonState == HIGH) {
    currentMode = (currentMode == "safe") ? "crash" : "safe";
    Serial.print("Mode toggled to: ");
    Serial.println(currentMode);

    // Notify the Flutter app about the new mode
    handleBluetoothNotifications(currentMode);
  }

  // Update the LED state based on the new mode
    ledState = (currentMode == "crash") ? HIGH : LOW;
    digitalWrite(LED_PIN, ledState);

  // Update the old button state
  oldButtonState = buttonState;

  delay(10); // Small delay to debounce the button
}