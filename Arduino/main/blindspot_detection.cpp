#include <Arduino.h>
#include "blindspot_detection.h"

// PWM config
const int pwmFreq = 200;
const int pwmRes = 8;

// Distance threshold in cm
const float distanceThresholdCm = 20.0;

// Debouncing variables
const int requiredConsistentReadings = 10;
int leftConsistentCount = 0;
int rightConsistentCount = 0;
bool lastLeftState = false;
bool lastRightState = false;
bool currentLeftLedState = false;
bool currentRightLedState = false;

void initBlindSpotTest() {
  // Setup PWM for each LRA
  ledcAttach(LEFT_LRA, pwmFreq, pwmRes);
  ledcAttach(RIGHT_LRA, pwmFreq, pwmRes);

  // Set LED pins as output
  pinMode(LEFT_LED_PIN, OUTPUT);
  pinMode(RIGHT_LED_PIN, OUTPUT);

  // Initialize LEDs to OFF
  digitalWrite(LEFT_LED_PIN, LOW);
  digitalWrite(RIGHT_LED_PIN, LOW);
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

  // Determine current blind spot states
  bool currentLeftDetected = leftCm < distanceThresholdCm;
  bool currentRightDetected = rightCm < distanceThresholdCm;

  // Handle LEFT debouncing
  if (currentLeftDetected == lastLeftState) {
    // Same state detected, increment counter
    leftConsistentCount++;
    
    // If we've seen the same state enough times, update the LED
    if (leftConsistentCount >= requiredConsistentReadings && currentLeftLedState != currentLeftDetected) {
      currentLeftLedState = currentLeftDetected;
      digitalWrite(LEFT_LED_PIN, currentLeftLedState ? HIGH : LOW);
    }
  } else {
    // Different state detected, reset counter
    leftConsistentCount = 1;
    lastLeftState = currentLeftDetected;
  }

  // Handle RIGHT debouncing
  if (currentRightDetected == lastRightState) {
    // Same state detected, increment counter
    rightConsistentCount++;
    
    // If we've seen the same state enough times, update the LED
    if (rightConsistentCount >= requiredConsistentReadings && currentRightLedState != currentRightDetected) {
      currentRightLedState = currentRightDetected;
      digitalWrite(RIGHT_LED_PIN, currentRightLedState ? HIGH : LOW);
    }
  } else {
    // Different state detected, reset counter
    rightConsistentCount = 1;
    lastRightState = currentRightDetected;
  }

  // Trigger vibration (kept unchanged from your code)
  bsLeftVibrate = leftCm < distanceThresholdCm;
  bsRightVibrate = rightCm < distanceThresholdCm;
  // ledcWrite(LEFT_LRA, (leftCm < distanceThresholdCm) ? vibrationMode : 0);
  // ledcWrite(RIGHT_LRA, (rightCm < distanceThresholdCm) ? vibrationMode : 0);
}