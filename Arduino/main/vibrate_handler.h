#ifndef VIBRATE_HANDLER_H
#define VIBRATE_HANDLER_H

#include <Arduino.h>

// Using the same pins defined in vibrate_settings.h
#define LEFT_LRA 33
#define RIGHT_LRA 32

// PWM configuration
#define PWM_FREQ 200  // 200 Hz works well for haptic LRAs
#define PWM_RES 8     // 8-bit (0-255)

// External variables
extern String currentMode;
extern int vibrationMode;
extern bool safeFlashing;
extern bool bsLeftVibrate;
extern bool bsRightVibrate;

// Function prototypes
void setupVibrateHandler();
void updateVibration();

#endif