#ifndef BUTTON_HANDLER_H
#define BUTTON_HANDLER_H

#include <Arduino.h>

#define BUTTON_PIN 4  // GPIO pin for the button

// Button constants
const unsigned long HOLD_THRESHOLD = 500; // 0.5 seconds for it to be considered not a tap
const unsigned long MODE_CHANGE_HOLD_TIME = 5000; // 5 seconds for mode change
const unsigned long TAP_TIMEOUT = 1000; // Max time between taps to count as consecutive
const unsigned long CANCEL_MODE_TIMEOUT = 15000; // 15 seconds to auto-switch to crash mode

// External variables
extern String currentMode;
extern int vibrationMode;
extern bool ledState;
extern int impactTime;

// Function prototypes
void setupButtonHandler();
void handleButtonPress(bool buttonState);
void handleTap();
void handleHold(unsigned long pressDuration);

#endif