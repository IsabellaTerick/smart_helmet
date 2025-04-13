#ifndef LED_HANDLER_H
#define LED_HANDLER_H

#include <Arduino.h>

#define LEFT_LED_PIN 26
#define RIGHT_LED_PIN 25
#define FORWARD_LED_PIN 27

// External variables
extern String currentMode;
extern bool ledState;

// Function prototypes
void setupLEDHandler();
void updateLED();

#endif