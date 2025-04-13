#include "LED_handler.h"
#include "forward_detection.h"
#include "blindspot_detection.h"

extern bool safeFlashing;

void setupLEDHandler() {
  // Set LED pins as output
  pinMode(LEFT_LED_PIN, OUTPUT);
  pinMode(RIGHT_LED_PIN, OUTPUT);
  pinMode(FORWARD_LED_PIN, OUTPUT);
  
  //Set initial LED state
  //digitalWrite(LEFT_LED_PIN, ledState);




}

void updateLED() {
  if (currentMode == "safe") {
    // Blind spot and forward collision detection
    if (safeFlashing) {
      digitalWrite(LEFT_LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
      digitalWrite(RIGHT_LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
      digitalWrite(FORWARD_LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);

    } else {
      //// TODO: put Blind Spot and Forward Collision here
      updateBlindSpotTest();
      updateForwardTest();

    }
  } else if (currentMode == "cancel") {
    // Flash LED
    digitalWrite(LEFT_LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
    digitalWrite(RIGHT_LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);
    digitalWrite(FORWARD_LED_PIN, (millis() / 250) % 2 ? HIGH : LOW);


  } else if (currentMode == "crash") {
    // Pulse LED
    digitalWrite(LEFT_LED_PIN, (millis() / 1000) % 2 ? HIGH : LOW);
    digitalWrite(RIGHT_LED_PIN, (millis() / 1000) % 2 ? HIGH : LOW);
    digitalWrite(FORWARD_LED_PIN, (millis() / 1000) % 2 ? HIGH : LOW);

  }
}