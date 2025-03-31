import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  late TwilioFlutter twilioFlutter;

  // Constructor
  TwilioService() {
    twilioFlutter = TwilioFlutter(
      accountSid: 'AC5ef8faf67b7a79889cefdfb6ac89d1e4',
      authToken: '8ae583a38a332a0c0b0a2f37b2dd6fcf',
      twilioNumber: '+18667192795',
    );
  }

  // Sending SMS message
  Future<void> sendSMS(String to, String message) async {
    try {
      await twilioFlutter.sendSMS(
        toNumber: to,
        messageBody: message,
      );
      print("SMS Sent Successfully!");
    } catch (e) {
      print("SMS not sent: $e");
    }
  }

  Future<void> sendCrashSMS(String link) async {
    String message = "Crash detected at: $link";
    await sendSMS('+14435548319', message); // Replace with recipient's number
  }

  Future<void> sendUpdateSMS(String link) async {
    String message = "User is on the move: $link";
    await sendSMS('+14435548319', message); // Replace with recipient's number
  }

  Future<void> sendSafeSMS() async {
    String message = "Safety confirmed.";
    await sendSMS('+14435548319', message); // Replace with recipient's number
  }
}