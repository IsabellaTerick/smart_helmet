#include <Arduino.h>
#include "resistor_handler.h"


void updateResistor() {
  int adcValue = analogRead(RESISTOR_PIN);
  float voltage = (adcValue / 4095.0) * 3.3;

  // Serial.print("Voltage: ");
  // Serial.println(voltage, 3);

  if (voltage > 2.0) {
    currentMode = "cancel";
    Serial.println("CRASH DETECTED: Switched to Cancel Mode");
  }
}
