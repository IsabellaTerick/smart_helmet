#ifndef LED_HANDLER_H
#define LED_HANDLER_H

#include <Arduino.h>

#define LED_PIN 4 // GPIO pin for the LED

// External variables
extern String currentMode;
extern bool ledState;

// Function prototypes
void setupLEDHandler();
void updateLED();

#endif