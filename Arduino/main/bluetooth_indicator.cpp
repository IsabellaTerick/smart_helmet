#include "bluetooth_indicator.h"

unsigned long previousMillis = 0;
const long flashInterval = 1000; // 500ms on, 500ms off = 1 second period
bool btStatusLedState = LOW;    // Status LED state

// Initialize the Bluetooth status indicator
void setupBluetoothIndicator() {
  pinMode(BT_STATUS_PIN, OUTPUT);
  digitalWrite(BT_STATUS_PIN, LOW); // Initially set pin 5 low (disconnected)
}

// Update the Bluetooth status indicator
void updateBluetoothIndicator(bool isConnected) {
  unsigned long currentMillis = millis();

  if (!isConnected) {
    // Flash the LED when not connected
    if (currentMillis - previousMillis >= flashInterval / 2) { // Half the interval for alternating on/off
      previousMillis = currentMillis;
      btStatusLedState = !btStatusLedState;
      digitalWrite(BT_STATUS_PIN, btStatusLedState);
    }
  } else {
    // Keep the LED on when connected
    digitalWrite(BT_STATUS_PIN, HIGH);
  }
}