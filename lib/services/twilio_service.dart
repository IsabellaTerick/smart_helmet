import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_manager.dart'; // Import NotificationManager
import '../services/firebase_service.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  late TwilioFlutter twilioFlutter;
  FirebaseService firebaseService = FirebaseService();

  // Constructor
  TwilioService() {
    twilioFlutter = TwilioFlutter(
      accountSid: 'AC5ef8faf67b7a79889cefdfb6ac89d1e4',
      authToken: '736d887d650a9d17b1251e98ba856504',
      twilioNumber: '+18667192795',
    );
  }

  // Helper method to format phone numbers
  String _formatPhoneNumber(String phoneNumber) {
    return phoneNumber.startsWith('+1') ? phoneNumber : '+1$phoneNumber';
  }

  // Universal method to send SMS with success/failure handling
  Future<bool> _sendSMS(BuildContext context, String to, String message) async {
    try {
      String formattedPhoneNumber = _formatPhoneNumber(to);

      await twilioFlutter.sendSMS(
        toNumber: formattedPhoneNumber,
        messageBody: message,
      );
      print("SMS Sent Successfully to $formattedPhoneNumber!");

      return true; // Indicate success
    } catch (e) {
      print("SMS not sent to $to: $e");

      // Trigger failure notification
      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
      notificationManager.showNotification(
        message: "Failed to send text messages",
        backgroundColor: Colors.red,
        icon: Icons.error,
      );

      return false; // Indicate failure
    }
  }

  // Universal method to send messages to multiple contacts
  Future<bool> _sendMessagesToContacts(
      BuildContext context,
      String mainMessage, {
        String? additionalMessage,
        String? link,
      }) async {
    try {
      String? userName = await firebaseService.getUserName();
      String? mode = await firebaseService.getMode();
      String? contactCrashMsg;
      List<String?>? phoneNums = await firebaseService.getEmergencyContactNumbers();
      List<String> contacts = (phoneNums ?? []).whereType<String>().toList();

      bool allMessagesSent = true; // Track if all messages were sent successfully

      for (String phoneNum in contacts) {
        String? personalizedMessage = '';

        if (mode == 'crash') {
          personalizedMessage = await firebaseService.getContactCustomCrashMsg(phoneNum);
          if (personalizedMessage == null || personalizedMessage == '') {
            personalizedMessage = additionalMessage;
          }
        }

        String fullMessage = _formatMessage(
          mainMessage: mainMessage,
          additionalMessage: personalizedMessage,
          link: link,
        );

        bool success = await _sendSMS(context, phoneNum, fullMessage);
        if (!success) {
          allMessagesSent = false; // Mark as failure if any message fails
        }
      }

      // Show overall success or failure notification
      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
      if (allMessagesSent) {
        notificationManager.showNotification(
          message: "Message sent!",
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
      } else {
        notificationManager.showNotification(
          message: "Failed to send",
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }

      return allMessagesSent;
    } catch (e) {
      print("Error sending messages: $e");

      // Trigger failure notification
      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
      notificationManager.showNotification(
        message: "Failed to send messages",
        backgroundColor: Colors.red,
        icon: Icons.error,
      );

      return false;
    }
  }

  // Helper method to format a message with optional details
  String _formatMessage({
    required String mainMessage,
    String? additionalMessage,
    String? link,
  }) {
    String formattedMessage = mainMessage;

    if (additionalMessage != null && additionalMessage.isNotEmpty) {
      formattedMessage += "\n\n\"$additionalMessage\"";
    }

    if (link != null && link.isNotEmpty) {
      formattedMessage += "\n\nLocation: $link";
    }

    return formattedMessage;
  }

  // Send crash alert
  Future<void> sendCrashSMS(BuildContext context, String link) async {
    String? crashMsg = await firebaseService.getCrashMsg();
    String? userName = await firebaseService.getUserName();

    String mainMessage =
        'Alert from Smart Helmet: ${userName ?? "Unknown User"} has been involved in a crash. Please check on them and contact emergency.';

    await _sendMessagesToContacts(
      context,
      mainMessage,
      additionalMessage: crashMsg,
      link: link,
    );
  }

  // Send update alert
  Future<void> sendUpdateSMS(BuildContext context, String link) async {
    String? userName = await firebaseService.getUserName();

    String mainMessage =
        'Alert from Smart Helmet: ${userName ?? "Unknown User"} is on the move.';

    await _sendMessagesToContacts(
      context,
      mainMessage,
      link: link,
    );
  }

  // Send safe confirmation
  Future<void> sendSafeSMS(BuildContext context) async {
    String? userName = await firebaseService.getUserName();

    String mainMessage =
        'Alert from Smart Helmet: ${userName ?? "Unknown User"} has confirmed their safety. No further action needed at this time.';

    await _sendMessagesToContacts(
      context,
      mainMessage,
    );
  }
}