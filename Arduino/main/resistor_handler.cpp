#include <Arduino.h>
#include "resistor_handler.h"

bool detected = false;

void updateResistor() {
  int adcValue = analogRead(RESISTOR_PIN);
  float voltage = (adcValue / 4095.0) * 3.3;
  

  if (voltage > 2.0) {
    if (!detected){
      detected = true;
      impactTime = millis();
      currentMode = "cancel";
      Serial.println("CRASH DETECTED: Switched to Cancel Mode");
    }
  }
  else{
    detected = false;
  }
}
