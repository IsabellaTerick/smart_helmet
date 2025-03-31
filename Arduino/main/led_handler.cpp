#include "LED_handler.h"

extern bool safeFlashing;

void setupLEDHandler() {
  pinMode(LED_PIN, OUTPUT); // Configure LED pin
  digitalWrite(LED_PIN, ledState); // Set initial LED state
}

void updateLED() {
  if (currentMode == "safe") {
    // Blind spot and forward collision detection
    if (safeFlashing) {
      digitalWrite(LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
    } else {
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