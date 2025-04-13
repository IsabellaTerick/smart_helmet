import 'package:flutter/material.dart';
import './help_guide.dart';

class HelpContent extends StatelessWidget {
  const HelpContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HelpGuide(
          icon: '👋',
          title: 'Who We Are',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Smart Helmet is a safety-first innovation designed to enhance motorcycle riders\' awareness and response times in critical moments. Our helmet integrates advanced features such as ',
                    ),
                    TextSpan(
                      text: 'blind spot detection',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'forward collision warning',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' to provide real-time situational awareness on the road. In the event of a crash, the helmet and its companion app work together to ',
                    ),
                    TextSpan(
                      text: 'automatically alert your emergency contacts',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ', sending your ',
                    ),
                    TextSpan(
                      text: 'real-time location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' to ensure that help can reach you as quickly as possible.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart Helmet is designed to give both you and your loved ones peace of mind. With intuitive alerts, customizable safety features, and seamless mobile connectivity, we\'re redefining what it means to ride smart.',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
            ],
          ),
        ),

        HelpGuide(
          icon: '🛠',
          title: 'Getting Started',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To begin using the Smart Helmet system, you will need to set up your profile and emergency settings.',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildNumberedPoint(1, 'Set Up Your Profile:', 'In the app settings, enter your name. This will appear in all alerts sent to your emergency contacts.'),
              _buildNumberedPoint(2, 'Default Crash Message:', 'Customize the default message that will be included in crash alerts unless a personalized message is assigned.'),
              _buildNumberedPoint(3, 'Add Emergency Contacts:', 'You can add up to 5 contacts by entering their names and phone numbers. Each contact may have their own custom crash message.'),
              _buildNumberedPoint(4, 'Connect to Bluetooth:', 'Tap the Bluetooth icon in the top-right corner to connect to your Smart Helmet. The helmet and app must remain connected via Bluetooth for crash detection and helmet-triggered alerts to function. You can still send crash alerts manually from the app even if the helmet is disconnected, but crash detection through impact or the helmet button will not function unless Bluetooth is connected.'),
              _buildNumberedPoint(5, 'Test the System:', 'Use the "Send Crash Alert" and "Confirm Safety" buttons in the app to test how alerts are sent. This helps verify everything is working correctly and gives your contacts a preview of what they might receive in an emergency.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '👥',
          title: 'Emergency Contacts',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('', 'The Smart Helmet system enables up to five emergency contacts.'),
              _buildBulletPoint('', 'Once a crash is detected, your contacts will receive real-time text alerts and location updates.'),
              _buildBulletPoint('', 'You cannot edit or remove your contacts while crash mode is active. After confirming your safety, you will regain access to make changes.'),
              _buildBulletPoint('', 'Each contact can have a custom crash message. If one is not set, the app will use the default crash message.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '⚙️',
          title: 'Crash Message Customization',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You can personalize how you communicate with your emergency contacts during a crash.',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Your Name:', 'This name will be included in all crash alert messages.'),
              _buildBulletPoint('Default Crash Message:', 'This is the general message sent to all contacts unless a specific one is provided.'),
              _buildBulletPoint('Custom Messages:', 'Tailor messages for individual contacts. Include instructions, reassurance, or code words to verify the message is legitimate.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '🚨',
          title: 'How Crash Detection Works',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The Smart Helmet can detect a crash through three methods:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Helmet Impact:', 'Built-in sensors detect significant force. You will have 15 seconds to cancel the alert by holding the helmet\'s button for 5 seconds or tapping it three times.'),
              _buildBulletPoint('Manual Trigger:', 'Press and hold the helmet\'s interact button for 5 seconds to manually initiate a crash alert.'),
              _buildBulletPoint('App Trigger:', 'Tap the "Send Crash Alert" button in the app to trigger crash mode manually.'),
              const SizedBox(height: 8),
              const Text(
                'When crash mode begins:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'Text alerts are sent to your emergency contacts with your name, custom message, and location.'),
              _buildBulletPoint('', 'All signal lights on the helmet will flash, and features like blind spot detection and forward collision warnings will be disabled.'),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Note: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Crash detection and alerts triggered by the helmet require an active Bluetooth connection with the app. If the helmet is not connected via Bluetooth, these alerts will not be sent. However, crash alerts can still be triggered manually through the app without a helmet connection.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        HelpGuide(
          icon: '📲',
          title: 'Crash & Safe Buttons',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'These buttons allow you to manually manage your emergency alert system:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Crash Button:', 'Immediately triggers a crash alert and sends your location to all emergency contacts.'),
              _buildBulletPoint('Safe Button:', 'Sends a message confirming your safety and disables crash mode, including location updates and flashing helmet signals.'),
              const SizedBox(height: 8),
              const Text(
                'You can activate crash mode either from the app or by holding the helmet\'s button for 5 seconds. The same helmet button is used to exit crash mode once you\'re safe.',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
            ],
          ),
        ),

        HelpGuide(
          icon: '📍',
          title: 'Real-Time Location Updates',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your location is monitored after a crash for better response and clarity.',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'If you move more than 0.25 miles from the crash location, an updated location link will be automatically sent to your emergency contacts.'),
              _buildBulletPoint('', 'Emergency contacts can text the word UPDATE to the system number to request your latest location at any time while crash mode is active.'),
              _buildBulletPoint('', 'Once you confirm your safety, all location tracking and updates stop.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '✅',
          title: 'Confirming You\'re Safe',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'When you\'re safe and no longer require assistance, you can confirm your status:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'Tap the "Confirm Safety" button in the app, or'),
              _buildBulletPoint('', 'Hold the helmet\'s interact button for 5 seconds until the flashing signal lights stop.'),
              const SizedBox(height: 8),
              const Text(
                'Once confirmed:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'Your emergency contacts will receive a safety confirmation message.'),
              _buildBulletPoint('', 'Your helmet\'s normal features will be restored.'),
              _buildBulletPoint('', 'You will regain the ability to edit your emergency contacts.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '🙌',
          title: 'Thank You for Riding with Smart Helmet',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We\'re proud to support your safety on the road with a system designed for clarity, responsiveness, and peace of mind. The Smart Helmet app ensures that help is always just a tap away. Ride with confidence knowing your loved ones are connected when it matters most.',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stay safe, and enjoy the ride.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontFamily: 'Nunito')),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold
              )
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}