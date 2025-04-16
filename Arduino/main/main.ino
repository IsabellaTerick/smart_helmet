#include "bluetooth_service.h"
#include "bluetooth_indicator.h"
#include "button_handler.h"
#include "led_handler.h"
#include "resistor_handler.h"
#include "vibrate_settings.h"
#include "blindspot_detection.h"
#include "forward_detection.h"
#include "vibrate_handler.h"

#define BUTTON_PIN 4  // GPIO pin for the button
#define BT_STATUS_PIN 5 // GPIO pin to indicate Bluetooth connection status
#define RESISTOR_PIN 35 // GPIO pin to detect crash status

String currentMode = "safe"; // Current mode from bluetooth_service
int vibrationMode = 0; // LED brightness level (0: low, 1: medium, 2: high)
bool ledState = LOW; // Initial state of the LED (off)
bool bsLeftVibrate = false;
bool bsRightVibrate = false;
int impactTime = 0;

void setup() {
  // Initialize button, LED, and vibrate handlers
  setupButtonHandler();
  setupLEDHandler();
  setupVibrateHandler();

  // Initialize Bluetooth and its indicator
  setupBluetooth();
  setupBluetoothIndicator();

  //setup Blindspot Detectionand Fwd Collision Warning
  initForwardTest();
  initBlindSpotTest();
}

void loop() {
  // Update the Bluetooth status indicator
  updateBluetoothIndicator(isDeviceConnected());

  // Handle button press logic
  bool buttonState = digitalRead(BUTTON_PIN);
  handleButtonPress(buttonState);

  // Check for a detected crash
  updateResistor();

  //Check for object in blind spots or forward collision
  updateBlindSpotTest();
  updateForwardTest();

  // Update LED behavior based on mode
  updateLED();

  // Update Vibrators based on LED behavior (max: 1 sec)
  updateVibration();

  delay(10); // Small delay to debounce the button
}