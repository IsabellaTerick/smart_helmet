#include <Arduino.h>
#include "forward_detection.h"

// Collision warning parameters
const float distanceThresholdCm = 200.0;      // Minimum detection distance (cm)
const float approachRateThreshold = 20.0;    // Minimum cm/sec approach rate to trigger warning
const unsigned long samplingInterval = 100;  // Time between readings (ms)
const int consecutiveReadingsNeeded = 3;     // Number of consecutive approaching readings needed

// Variables to track previous readings
float previousDistances[5] = {0};           // Store last several readings
int readingIndex = 0;                        // Current index in the buffer
unsigned long lastReadingTime = 0;
int approachingCount = 0;                    // Counter for consecutive approaching readings

// Debug flag
const bool enableDebugOutput = true;

void initForwardTest() {
  pinMode(FORWARD_LED_PIN, OUTPUT);
  digitalWrite(FORWARD_LED_PIN, LOW);  // Start with LED OFF
  
  // Initialize with first reading
  int adcValue = analogRead(FORWARD_COLLISION);
  float voltage = adcValue * (3.3 / 4095.0);
  float distanceInches = voltage / 0.006445;
  float initialDistanceCm = distanceInches * 2.54;
  
  // Initialize buffer with initial reading
  for (int i = 0; i < 5; i++) {
    previousDistances[i] = initialDistanceCm;
  }
  
  lastReadingTime = millis();
  
  if (enableDebugOutput) {
    Serial.println("Forward collision detection initialized");
    Serial.print("Initial distance: ");
    Serial.print(initialDistanceCm);
    Serial.println(" cm");
  }
}

void updateForwardTest() {
  unsigned long currentTime = millis();
  
  // Only take readings at the defined interval
  if (currentTime - lastReadingTime >= samplingInterval) {
    float timeElapsedSec = (currentTime - lastReadingTime) / 1000.0;
    
    // Get current reading
    int adcValue = analogRead(FORWARD_COLLISION);
    float voltage = adcValue * (3.3 / 4095.0);
    float distanceInches = voltage / 0.006445;
    float currentDistanceCm = distanceInches * 2.54;
    
    // Calculate the rate of approach (cm/sec)
    float previousAvg = (previousDistances[0] + previousDistances[1] + previousDistances[2]) / 3.0;
    float approachRate = (previousAvg - currentDistanceCm) / timeElapsedSec;
    
    // Update the readings buffer
    previousDistances[readingIndex] = currentDistanceCm;
    readingIndex = (readingIndex + 1) % 5;
    
    // Debug output
    if (enableDebugOutput) {
      Serial.print("Distance: ");
      Serial.print(currentDistanceCm, 1);
      Serial.print(" cm | Previous Avg: ");
      Serial.print(previousAvg, 1);
      Serial.print(" cm | Approach Rate: ");
      Serial.print(approachRate, 1);
      Serial.print(" cm/s | Count: ");
      Serial.println(approachingCount);
    }
    
    // Update our consecutive approaching counter
    if (approachRate >= approachRateThreshold) {
      approachingCount++;
      if (enableDebugOutput && approachingCount > 0) {
        Serial.print("Approaching detected (");
        Serial.print(approachingCount);
        Serial.print("/");
        Serial.print(consecutiveReadingsNeeded);
        Serial.println(")");
      }
    } else {
      // Reset counter if not approaching fast enough
      approachingCount = 0;
    }
    
    // Warning logic: 
    // 1. Must be within range
    // 2. Must have sufficient consecutive fast approaches
    bool warningCondition = (currentDistanceCm < distanceThresholdCm && 
                           approachingCount >= consecutiveReadingsNeeded);
    
    if (warningCondition) {
      digitalWrite(FORWARD_LED_PIN, HIGH);  // LED ON
      if (enableDebugOutput) {
        Serial.println("WARNING: Fast approaching object detected!");
      }
    } else {
      digitalWrite(FORWARD_LED_PIN, LOW);  // LED OFF
    }
    
    lastReadingTime = currentTime;
  }
}