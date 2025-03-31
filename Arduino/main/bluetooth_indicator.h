#ifndef BLUETOOTH_INDICATOR_H
#define BLUETOOTH_INDICATOR_H

#include <Arduino.h>

#define BT_STATUS_PIN 5 // GPIO pin to indicate Bluetooth connection status

// Public functions
void setupBluetoothIndicator();
void updateBluetoothIndicator(bool isConnected);

#endif