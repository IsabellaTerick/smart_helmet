import 'package:flutter/material.dart';

class ButtonHandler {
  bool _buttonColor = false; // Tracks the button color

  // Getter for button color
  Color getButtonColor() {
    return _buttonColor ? Colors.blue : Colors.red;
  }

  // Toggle button color (called when ESP32 sends "BUTTON_PRESSED")
  void toggleButtonColor() {
    _buttonColor = !_buttonColor;
  }

  // Reset button color (optional, if needed)
  void resetButtonColor() {
    _buttonColor = false;
  }
}