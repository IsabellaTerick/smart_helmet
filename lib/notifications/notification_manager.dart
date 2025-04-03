import 'package:flutter/material.dart';

class NotificationManager with ChangeNotifier {
  String _message = '';
  bool _isVisible = false;
  Color _backgroundColor = Colors.red;
  IconData? _icon;

  String get message => _message;
  bool get isVisible => _isVisible;
  Color get backgroundColor => _backgroundColor;
  IconData? get icon => _icon;

  void showNotification({
    required String message,
    Color backgroundColor = Colors.red,
    IconData? icon,
  }) {
    _message = message;
    _backgroundColor = backgroundColor;
    _icon = icon;
    _isVisible = true;
    notifyListeners();

    // Automatically hide the notification after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _isVisible = false;
      notifyListeners();
    });
  }

  void hideNotification() {
    _isVisible = false;
    notifyListeners();
  }
}