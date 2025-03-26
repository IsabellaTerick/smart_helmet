#include "bluetooth_service.h"
#include "bluetooth_indicator.h"

#define BUTTON_PIN 2  // GPIO pin for the button
#define LED_PIN 4     // GPIO pin for the LED

bool oldButtonState = LOW;
unsigned long lastPressTime = 0; // Track time of last button press
int tapCount = 0; // Track consecutive taps
unsigned long holdStartTime = 0; // Track when the button was first pressed
bool isHolding = false; // Track if the button is being held
bool safeFlashing = false;
bool holdHandled = false;
extern String currentMode; // Current mode from bluetooth_service
int vibrationMode = 0; // LED brightness level (0: low, 1: medium, 2: high)
bool ledState = LOW; // Initial state of the LED (off)

// Define constants for timing
const unsigned long HOLD_THRESHOLD = 500; // 0.5 seconds for it to be considered not a tap
const unsigned long WARNING_THRESHOLD = 2000; // 2 seconds until the LEDs flash warning you that you are entering crash mode
const unsigned long MODE_CHANGE_HOLD_TIME = 5000; // 5 seconds for mode change
const unsigned long TAP_TIMEOUT = 1000; // Max time between taps to count as consecutive
const unsigned long CANCEL_MODE_TIMEOUT = 15000; // 15 seconds to auto-switch to crash mode

void setup() {
  // Configure pins
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, ledState); // Set initial LED state

  // Initialize Bluetooth and its indicator
  setupBluetooth();
  setupBluetoothIndicator();

  // Initialize mode and LED brightness
  currentMode = "cancel";
  vibrationMode = 0;
}

void loop() {
  // Update the Bluetooth status indicator
  updateBluetoothIndicator(isDeviceConnected());

  // Read the button state
  bool buttonState = digitalRead(BUTTON_PIN);
  unsigned long pressDuration = millis() - holdStartTime;

  // Handle button press logic
  if (buttonState == HIGH) { // Button pressed
    lastPressTime = millis(); // Tracks until the button is released

    if (!isHolding) {
      holdStartTime = millis(); // Tracks from the start of the button press
      isHolding = true;
      // Serial.println("Holding = True");
    }
    else if (!holdHandled) {
      handleHold(pressDuration);
    }

    if (pressDuration % 1000 == 0) {
      Serial.print("Press Duration: ");
      Serial.println(pressDuration/1000);
    }
  }

  // Handle button release logic
  if (buttonState == LOW && oldButtonState == HIGH) { // Button released
    // Serial.println("Button Released");

    if (pressDuration <= HOLD_THRESHOLD) { // Short press (tap)
      handleTap();
    }

    // Reset hold state
    isHolding = false;
    holdHandled = false;
    safeFlashing = false;
  }

  // Handle consecutive taps timeout
  if (millis() - lastPressTime > TAP_TIMEOUT) {
    tapCount = 0; // Reset tap count if timeout occurs
  }

  // Handle cancel mode timeout
  if (currentMode == "cancel" && millis() - lastPressTime > CANCEL_MODE_TIMEOUT) {
    currentMode = "crash"; // Auto-switch to crash mode
    Serial.println("Timed out: Crash Mode");
    handleBluetoothNotifications(currentMode);
  }

  // Update LED behavior based on mode
  updateLED();

  // Update the old button state
  oldButtonState = buttonState;

  delay(10); // Small delay to debounce the button
}

void handleTap() {
  if (currentMode == "safe") {
    // Change LED brightness on tap
    vibrationMode = (vibrationMode + 1) % 3; // Cycle through low, medium, high
    Serial.print("Vibration mode set to: ");
    Serial.println(vibrationMode);
  } else if (currentMode == "cancel") {
    // Count consecutive taps to revert to safe mode
    if (tapCount >= 2) {
      currentMode = "safe";
      tapCount = 0; // Reset tap count
      Serial.println("Tapped 3 times: Safe Mode");
      handleBluetoothNotifications(currentMode);
    }
    else {
      tapCount++; // Increment tap count
      Serial.print("Tap Count:");
      Serial.println(tapCount);
    }
  }
}

void handleHold(unsigned long pressDuration) {
  if (currentMode == "safe") {
    if (pressDuration >= MODE_CHANGE_HOLD_TIME) {
      currentMode = "crash"; // Switch to crash mode
      Serial.println("Switched to Crash Mode");
      handleBluetoothNotifications(currentMode);
      holdHandled = true;
      safeFlashing = false;
      Serial.println("Hold handled");

    } else if (pressDuration >= HOLD_THRESHOLD) {
      safeFlashing = true;
    }
  } else if (currentMode == "crash") {
    if (pressDuration >= MODE_CHANGE_HOLD_TIME) {
      currentMode = "safe"; // Switch to safe mode
      holdHandled = true;
      Serial.println("Switched to Safe Mode");
      handleBluetoothNotifications(currentMode);
    }
  }
}

void updateLED() {
  if (currentMode == "safe") {
    // Blind spot and forward collision detection
    if (safeFlashing) {
      digitalWrite(LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
    }
    else {
      //// TODO: put Blind Spot and Forward Collision here
      digitalWrite(LED_PIN, LOW);
    }
  } else if (currentMode == "cancel") {
    // Flash LED
    digitalWrite(LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
  } else if (currentMode == "crash") {
    // Pulse LED
    digitalWrite(LED_PIN, (millis() / 1000) % 2 ? HIGH : LOW);
  }
}