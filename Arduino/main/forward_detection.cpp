#include <Arduino.h>
#include "forward_detection.h"

const int ledPin = 2;     // Onboard blue LED (active-low on most ESP32s)

// LED turns on if object is closer than this (in cm)
const float distanceThresholdCm = 50.0;

void initForwardTest() {
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, HIGH); // Start with LED OFF (active-low)
}

void updateForwardTest() {
  int adcValue = analogRead(FORWARD_COLLISION);
  float voltage = adcValue * (3.3 / 4095.0);          // Convert ADC to voltage
  float distanceInches = voltage / 0.006445;          // From datasheet (3.3V / 512)
  float distanceCm = distanceInches * 2.54;           // Convert to cm

  Serial.print("ADC: ");
  Serial.print(adcValue);
  Serial.print(" | Voltage: ");
  Serial.print(voltage, 3);
  Serial.print(" V | Distance: ");
  Serial.print(distanceCm, 1);
  Serial.println(" cm");

  if (distanceCm < distanceThresholdCm) {
    digitalWrite(ledPin, HIGH);  // LED ON (active-low)
  } else {
    digitalWrite(ledPin, LOW); // LED OFF
  }
}
