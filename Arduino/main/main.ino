#include "bluetooth_service.h"
#include "bluetooth_indicator.h"
#include "button_handler.h"
#include "led_handler.h"
#include "resistor_handler.h"
#include "vibrate_handler.h"

#define BUTTON_PIN 2  // GPIO pin for the button
#define LED_PIN 4 // GPIO pin for the LED
#define BT_STATUS_PIN 5 // GPIO pin to indicate Bluetooth connection status
#define RESISTOR_PIN 35 // GPIO pin to detect crash status

String currentMode = "safe"; // Current mode from bluetooth_service
int vibrationMode = 0; // LED brightness level (0: low, 1: medium, 2: high)
bool ledState = LOW; // Initial state of the LED (off)

void setup() {
  // Initialize button, LED, and vibrate handlers
  setupButtonHandler();
  setupLEDHandler();
  setupVibrateHandler();

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

  // Check for a detected crash
  updateResistor();

  // Update LED behavior based on mode
  updateLED();

  // Update Vibrators based on LED behavior (max: 1 sec)
  updateVibration();

  delay(10); // Small delay to debounce the button
}