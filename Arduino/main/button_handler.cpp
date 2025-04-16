#include "button_handler.h"
#include "bluetooth_service.h"

// Internal variables
bool oldButtonState = HIGH;
unsigned long lastPressTime = 0; // Track time of last button press
int tapCount = 0; // Track consecutive taps
unsigned long holdStartTime = 0; // Track when the button was first pressed
bool isHolding = false; // Track if the button is being held
bool holdHandled = false;
bool safeFlashing = false;

void setupButtonHandler() {
  pinMode(BUTTON_PIN, INPUT_PULLUP); // Configure button pin
}

void handleButtonPress(bool buttonState) {
  unsigned long pressDuration = millis() - holdStartTime;

  // Handle button press logic
  if (buttonState == LOW) { // Button pressed
    lastPressTime = millis(); // Tracks until the button is released

    if (!isHolding) {
      holdStartTime = millis(); // Tracks from the start of the button press
      isHolding = true;
    } else if (!holdHandled) {
      handleHold(pressDuration);
    }

    if (pressDuration % 1000 == 0) {
      Serial.print("Hold Duration: ");
      Serial.println(pressDuration / 1000);
    }
  }

  // Handle button release logic
  if (buttonState == HIGH && oldButtonState == LOW) { // Button released
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
  if (currentMode == "cancel" && millis() - impactTime > CANCEL_MODE_TIMEOUT) {
    currentMode = "crash"; // Auto-switch to crash mode
    Serial.println("Timed out: Crash Mode");
    handleBluetoothNotifications(currentMode);
  }

  // Update the old button state
  oldButtonState = buttonState;
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
    } else {
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
  } else if (currentMode == "cancel") {
    if (pressDuration >= MODE_CHANGE_HOLD_TIME) {
      currentMode = "safe"; // Switch to safe mode
      holdHandled = true;
      Serial.println("Returned to Safe Mode");
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