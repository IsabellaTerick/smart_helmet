#include <Arduino.h>
#include "forward_detection.h"

// LED turns on if object is closer than this (in cm)
const float distanceThresholdCm = 50.0;

void initForwardTest() {

  // Set LED pins as output
  pinMode(FORWARD_LED_PIN, OUTPUT);

}

void updateForwardTest() {
  // FORWARD Sensor
  int forwardAdc = analogRead(FORWARD_COLLISION);
  float forwardVolt = forwardAdc * (3.3 / 4095.0);
  float forwardCm = (forwardVolt / 0.006445) * 2.54;


    // FORWARD LED
  digitalWrite(FORWARD_LED_PIN, (forwardCm < distanceThresholdCm) ? HIGH : LOW);


}
