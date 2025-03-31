import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  late TwilioFlutter twilioFlutter;

  //Constructor
  TwilioService() {
    twilioFlutter = TwilioFlutter (
      accountSid: 'AC5ef8faf67b7a79889cefdfb6ac89d1e4',
      authToken: '8ae583a38a332a0c0b0a2f37b2dd6fcf',
      twilioNumber: '+18667192795',
    );
  }

  //Sending SMS message
  Future<void> sendSMS(String to, String message) async {
    try {
      await twilioFlutter.sendSMS(
        toNumber: to,
        messageBody: message,
      );
      print("SMS Sent Successfully!");
    } catch (e) {
      print("SMS not sent.");
    }
  }

  Future<void> sendCrashSMS(String link) async {
    String? crashMsg = await firebaseService.getCrashMsg();
    String? userName = await firebaseService.getUserName();
    List<String?>? phoneNums = await firebaseService.getEmergencyContactNumbers();
    List<String> contacts = (phoneNums ?? []) as List<String>;

    var msg = '';
    if (mode == "safe" || mode == "crash") {
      _sendStatus.sendMode(mode); // Send the mode to the microcontroller
      _updateMode(mode); // Update the local mode
    }

    //Iterate through list of emergency contacts
    if (phoneNums != null && contacts.isNotEmpty) {
      for (String phoneNum in contacts) {
        //Send out safe message
        if (mode == "safe") {
          twilioService.sendCrashSMS(phoneNum, msg);
        }
        //Send out crash message
        else if (mode == "crash") {
          msg = 'Alert from Smart Helmet: ${userName ?? "Unknown User"} has been involved in a crash. Please check on them and contact emergency. "${crashMsg ?? ""}"';
          twilioService.sendSMS(phoneNum, msg);
        } else {
          print("Unknown mode set.");
        }
      }
    }
  }

  Future<void> sendUpdateSMS(String link) async { }

  Future<void> sendSafeSMS() async { }
}