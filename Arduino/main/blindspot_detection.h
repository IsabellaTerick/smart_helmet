#ifndef BLINDSPOT_DETECTION_H
#define BLINDSPOT_DETECTION_H

#define BUTTON_PIN 4
#define LEFT_LRA 33
#define RIGHT_LRA 32

#define LEFT_BLINDSPOT 36
#define RIGHT_BLINDSPOT 39

#define LEFT_LED_PIN 26
#define RIGHT_LED_PIN 25

extern int vibrationMode;
extern bool bsLeftVibrate;
extern bool bsRightVibrate;

void initBlindSpotTest();
void updateBlindSpotTest();

#endif
