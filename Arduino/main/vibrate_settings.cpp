#include "vibrate_settings.h"

const int ledPin = 2;        // Onboard blue LED

// PWM configuration
const int pwmFreq = 200;     // 200 Hz works well for haptic LRAs
const int pwmResolution = 8; // 8-bit (0–255)

unsigned long buttonPressTime = 0;
bool buttonPreviouslyPressed = false;
bool ledOn = false;

// int vibrationMode = 0; // 0 = None, 1 = Low, 2 = High (defined in main now)

void applyVibration(int mode, int durationMs) {
  int duty = 0;

  switch (mode) {
    case 1: duty = 150; break;   // Low power vibration
    case 2: duty = 255; break;   // Full power
    default: duty = 0; break;    // No vibration
  }

  ledcWrite(RIGHT_LRA, duty);
  ledcWrite(LEFT_LRA, duty);

  delay(durationMs);

  ledcWrite(RIGHT_LRA, 0);
  ledcWrite(LEFT_LRA, 0);
}

void initTestButton() {
  pinMode(BUTTON_PIN, INPUT_PULLUP); // Button is active LOW
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);

  // Use new ESP32 3.x API: attach PWM directly to pins
  ledcAttach(RIGHT_LRA, pwmFreq, pwmResolution);
  ledcAttach(LEFT_LRA, pwmFreq, pwmResolution);
}

void updateTestButton() {
  bool buttonPressed = digitalRead(BUTTON_PIN) == LOW;
  unsigned long currentTime = millis();

  if (buttonPressed) {
    if (!buttonPreviouslyPressed) {
      buttonPressTime = currentTime;
      buttonPreviouslyPressed = true;
    }

    if ((currentTime - buttonPressTime) >= 5000 && !ledOn) {
      digitalWrite(ledPin, HIGH);
      ledOn = true;
    }
  } else {
    if (buttonPreviouslyPressed) {
      unsigned long heldTime = currentTime - buttonPressTime;

      if (heldTime < 5000) {
        vibrationMode = (vibrationMode + 1) % 3;
        Serial.print("Vibration Mode: ");
        Serial.println(vibrationMode);
        applyVibration(vibrationMode, 1000); // Vibrate for 1 sec
      }

      buttonPreviouslyPressed = false;
    }
  }
}
