#include <Arduino.h>
#include "blindspot_detection.h"

// PWM config
const int pwmFreq = 200;
const int pwmRes = 8;

// Distance threshold in cm
const float distanceThresholdCm = 50.0;

void initBlindSpotTest() {
  // Setup PWM for each LRA
  ledcAttach(LEFT_LRA, pwmFreq, pwmRes);
  ledcAttach(RIGHT_LRA, pwmFreq, pwmRes);
}

void updateBlindSpotTest() {
  // LEFT
  int leftAdc = analogRead(LEFT_BLINDSPOT);
  float leftVolt = leftAdc * (3.3 / 4095.0);
  float leftCm = (leftVolt / 0.006445) * 2.54;

  // RIGHT
  int rightAdc = analogRead(RIGHT_BLINDSPOT);
  float rightVolt = rightAdc * (3.3 / 4095.0);
  float rightCm = (rightVolt / 0.006445) * 2.54;

  Serial.print("Left: ");
  Serial.print(leftCm, 1);
  Serial.print(" cm | Right: ");
  Serial.print(rightCm, 1);
  Serial.println(" cm");

  // Trigger vibration
  ledcWrite(LEFT_LRA, leftCm < distanceThresholdCm ? 255 : 0);
  ledcWrite(RIGHT_LRA, rightCm < distanceThresholdCm ? 255 : 0);
}
