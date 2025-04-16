#include "vibrate_handler.h"

// Variables to track vibration duration
unsigned long vibrationStartTime = 0;
bool isVibrating = false;

void setupVibrateHandler() {
  // Use ESP32 3.x API: attach PWM directly to pins
  ledcAttach(LEFT_LRA, PWM_FREQ, PWM_RES);
  ledcAttach(RIGHT_LRA, PWM_FREQ, PWM_RES);
  
  // Start with vibration off
  ledcWrite(LEFT_LRA, 0);
  ledcWrite(RIGHT_LRA, 0);
}

void updateVibration() {
  unsigned long currentTime = millis();
  int duty = 0;
  bool shouldVibrate = false;

  // Calculate vibration strength based on vibrationMode
  switch (vibrationMode) {
    case 1: duty = 150; break;   // Low power vibration
    case 2: duty = 255; break;   // Full power
    default: duty = 0; break;    // No vibration
  }

  if (currentMode == "safe") {
    // Blind spot and forward collision detection
    if (safeFlashing) {
      shouldVibrate = (millis() / 250) % 2 ? true : false; // Match LED pattern
    } else {
      shouldVibrate = bsLeftVibrate || bsLeftVibrate;
    }
  } else if (currentMode == "cancel") {
    // Flash vibration
    shouldVibrate = (millis() / 250) % 2 ? true : false; // Match LED pattern
  } else if (currentMode == "crash") {
    // No vibration
    shouldVibrate = false;
  }

  // Check if vibration time > 1 second
  if (isVibrating && (currentTime - vibrationStartTime >= 1000)) {
    shouldVibrate = false;
  }
  
  // Apply vibration changes
  if (shouldVibrate && duty > 0) {
    if (!isVibrating) {
      if (currentMode == "safe") {
        // Blind spot and forward collision detection
        if (safeFlashing) {
          int leftDuty = duty ? bsLeftVibrate : 0;
          int rightDuty = duty ? bsRightVibrate : 0;
          ledcWrite(LEFT_LRA, leftDuty);
          ledcWrite(RIGHT_LRA, rightDuty);
          return;
        }
      }
      // Start new vibration and record time
      ledcWrite(LEFT_LRA, duty);
      ledcWrite(RIGHT_LRA, duty);
      vibrationStartTime = currentTime;
      isVibrating = true;
    }
  }
  else {
    // Stop vibration
    if (isVibrating) {
      ledcWrite(LEFT_LRA, 0);
      ledcWrite(RIGHT_LRA, 0);
      isVibrating = false;
    }
  }
}