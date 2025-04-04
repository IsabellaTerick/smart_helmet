#include "bluetooth_service.h"
#include "bluetooth_indicator.h"
#include "button_handler.h"
#include "led_handler.h"

#define BUTTON_PIN 2  // GPIO pin for the button
#define LED_PIN 4 // GPIO pin for the LED
#define BT_STATUS_PIN 5 // GPIO pin to indicate Bluetooth connection status

String currentMode = "cancel"; // Current mode from bluetooth_service
int vibrationMode = 0; // LED brightness level (0: low, 1: medium, 2: high)
bool ledState = LOW; // Initial state of the LED (off)

void setup() {
  // Initialize button and LED handlers
  setupButtonHandler();
  setupLEDHandler();

  // Initialize Bluetooth and its indicator
  setupBluetooth();
  setupBluetoothIndicator();
}

void loop() {
  // Update the Bluetooth status indicator
  updateBluetoothIndicator(isDeviceConnected());

  // Handle button press logic
  bool buttonState = digitalRead(BUTTON_PIN);
  handleButtonPress(buttonState);

  // Update LED behavior based on mode
  updateLED();

  delay(10); // Small delay to debounce the button
}