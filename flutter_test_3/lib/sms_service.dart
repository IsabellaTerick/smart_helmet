import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsService {
  static const accountSid = "AC5ef8faf67b7a79889cefdfb6ac89d1e4";
  static const authToken = "8ae583a38a332a0c0b0a2f37b2dd6fcf";
  static const twilioNumber = "+18667192795";                     // Toll-free number
  static const recipientNumber = "+14435548319";                  // Your phone number

  static Future<void> sendSms(String message) async {
    final response = await http.post(
      Uri.parse("https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json"),
      headers: {
        "Authorization": "Basic " + base64Encode(utf8.encode("$accountSid:$authToken")),
      },
      body: {
        "From": twilioNumber,
        "To": recipientNumber,
        "Body": message,
      },
    );

    if (response.statusCode == 201) {
      print("SMS sent successfully!");
    } else {
      print("Failed to send SMS: ${response.body}");
    }
  }
}